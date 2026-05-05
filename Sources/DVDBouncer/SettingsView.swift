import SwiftUI
import AppKit

struct SettingsView: View {
    @Bindable var state: DVDState
    var isOverlayVisible: Bool
    var onToggleOverlay: () -> Void
    var onAimAtCorner: () -> Void
    var onTriggerCelebration: () -> Void
    var onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                DVDLogoView(color: state.color, mainText: state.mainText, subText: state.subText)
                    .frame(width: 60, height: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text("DVD Bouncer")
                        .font(.headline)
                    Text("Corner hits: \(state.cornerHits)  •  Walls: \(state.wallBounces)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Size")
                        .frame(width: 50, alignment: .leading)
                    Slider(value: $state.logoWidth, in: 80...520, step: 4)
                    Text("\(Int(state.logoWidth))")
                        .font(.caption.monospacedDigit())
                        .frame(width: 36, alignment: .trailing)
                }
                HStack {
                    Text("Speed")
                        .frame(width: 50, alignment: .leading)
                    Slider(value: $state.speed, in: 60...900, step: 10)
                    Text("\(Int(state.speed))")
                        .font(.caption.monospacedDigit())
                        .frame(width: 36, alignment: .trailing)
                }
                Toggle("Corner hit celebration", isOn: $state.celebrationsEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                HStack {
                    Text("Logo")
                        .frame(width: 50, alignment: .leading)
                    TextField("Main", text: $state.mainText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: state.mainText) { _, new in
                            if new.count > 5 { state.mainText = String(new.prefix(5)) }
                        }
                    TextField("Sub", text: $state.subText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onChange(of: state.subText) { _, new in
                            if new.count > 8 { state.subText = String(new.prefix(8)) }
                        }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Debug")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Button(action: onAimAtCorner) {
                        Label("Aim at Corner", systemImage: "scope")
                    }
                    .help("ロゴを 4 角のいずれかへ確実に向かう軌道に強制セット。実物理で角ヒットする。")

                    Button(action: onTriggerCelebration) {
                        Label("Force FX", systemImage: "sparkles")
                    }
                    .help("演出（音＋ビジュアル）だけ即時発動。ロゴの軌道は変えない。")
                }
            }

            Divider()

            HStack(spacing: 8) {
                Button(isOverlayVisible ? "Hide Logo" : "Show Logo", action: onToggleOverlay)
                Spacer()
                Button("Quit", role: .destructive, action: onQuit)
                    .keyboardShortcut("q")
            }

            Text("Tip: ⌥クリックでメニューバーに残り壁ヒット数を表示")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 340)
    }
}
