import AppKit
import QuartzCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: NSWindow?
    private var state: DVDState?
    private var tickTask: Task<Void, Never>?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var popoverMonitor: Any?
    private var isOverlayVisible: Bool = true
    private var predictionMode: Bool = false
    private var lastSeenWallBounces: Int = -1
    private var lastPredictionRefreshAt: CFTimeInterval = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else {
            NSLog("DVDBouncer: no main screen")
            NSApp.terminate(nil)
            return
        }
        let frame = screen.frame

        let state = DVDState(screenSize: frame.size)
        self.state = state

        buildOverlayWindow(frame: frame, state: state)
        buildStatusItem(state: state)

        self.tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self, let s = self.state else { return }
                s.tick(now: CACurrentMediaTime())
                if self.predictionMode {
                    let now = CACurrentMediaTime()
                    let bouncesChanged = s.wallBounces != self.lastSeenWallBounces
                    let isStale = (now - self.lastPredictionRefreshAt) > 0.5
                    if bouncesChanged || isStale {
                        self.lastSeenWallBounces = s.wallBounces
                        self.lastPredictionRefreshAt = now
                        self.refreshPrediction()
                    }
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        tickTask?.cancel()
        if let monitor = popoverMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func buildOverlayWindow(frame: NSRect, state: DVDState) {
        let win = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: NSScreen.main
        )
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = false
        win.level = .screenSaver
        win.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        win.ignoresMouseEvents = true
        win.isReleasedWhenClosed = false

        let host = NSHostingView(rootView: DVDOverlayView(state: state))
        host.frame = NSRect(origin: .zero, size: frame.size)
        host.autoresizingMask = [.width, .height]
        win.contentView = host

        win.orderFrontRegardless()
        self.overlayWindow = win
    }

    private func buildStatusItem(state: DVDState) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let img = NSImage(systemSymbolName: "opticaldisc.fill", accessibilityDescription: "DVD Bouncer")
            img?.isTemplate = true
            button.image = img
            button.imagePosition = .imageOnly
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        self.statusItem = item

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentSize = NSSize(width: 340, height: 320)
        pop.contentViewController = NSHostingController(
            rootView: SettingsView(
                state: state,
                isOverlayVisible: isOverlayVisible,
                onToggleOverlay: { [weak self] in self?.toggleOverlayVisibility() },
                onAimAtCorner: { [weak self] in self?.state?.aimAtCorner() },
                onTriggerCelebration: { [weak self] in self?.state?.triggerCelebrationOnly() },
                onQuit: { NSApp.terminate(nil) }
            )
        )
        self.popover = pop
    }

    private func rebuildSettingsView() {
        guard let pop = popover, let state else { return }
        pop.contentViewController = NSHostingController(
            rootView: SettingsView(
                state: state,
                isOverlayVisible: isOverlayVisible,
                onToggleOverlay: { [weak self] in self?.toggleOverlayVisibility() },
                onAimAtCorner: { [weak self] in self?.state?.aimAtCorner() },
                onTriggerCelebration: { [weak self] in self?.state?.triggerCelebrationOnly() },
                onQuit: { NSApp.terminate(nil) }
            )
        )
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        let event = NSApp.currentEvent
        let modifiers = event?.modifierFlags ?? []
        let isRightClick = event?.type == .rightMouseUp
        if modifiers.contains(.option) || isRightClick {
            togglePredictionMode()
            return
        }
        toggleSettingsPopover(sender)
    }

    private func toggleSettingsPopover(_ sender: Any?) {
        guard let pop = popover, let button = statusItem?.button else { return }
        if pop.isShown {
            pop.performClose(sender)
        } else {
            rebuildSettingsView()
            pop.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            pop.contentViewController?.view.window?.makeKey()
        }
    }

    private func togglePredictionMode() {
        predictionMode.toggle()
        if predictionMode {
            lastSeenWallBounces = state?.wallBounces ?? -1
            refreshPrediction()
        } else {
            statusItem?.button?.title = ""
            statusItem?.button?.imagePosition = .imageOnly
        }
    }

    private func refreshPrediction() {
        guard predictionMode, let state, let button = statusItem?.button else { return }
        let label: String
        if let n = state.bouncesUntilCorner() {
            label = "  \(n)"
        } else {
            label = "  ∞"
        }
        button.title = label
        button.imagePosition = .imageLeading
        let attr = NSMutableAttributedString(string: label)
        attr.addAttributes(
            [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .semibold)
            ],
            range: NSRange(location: 0, length: attr.length)
        )
        button.attributedTitle = attr
    }

    private func toggleOverlayVisibility() {
        isOverlayVisible.toggle()
        if isOverlayVisible {
            overlayWindow?.orderFrontRegardless()
        } else {
            overlayWindow?.orderOut(nil)
        }
        rebuildSettingsView()
    }
}
