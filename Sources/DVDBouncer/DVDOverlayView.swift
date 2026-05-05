import SwiftUI
import QuartzCore

struct DVDOverlayView: View {
    @Bindable var state: DVDState

    private let celebrationDuration: Double = 2.4

    var body: some View {
        TimelineView(.animation) { _ in
            let now = CACurrentMediaTime()
            let elapsed = celebrationElapsed(now: now)
            let punchScale = logoPunchScale(elapsed: elapsed)
            let logoColor = currentLogoColor(elapsed: elapsed)
            let glow = currentGlow(elapsed: elapsed)

            ZStack(alignment: .topLeading) {
                Color.clear

                DVDLogoView(color: logoColor, mainText: state.mainText, subText: state.subText)
                    .frame(width: state.logoSize.width, height: state.logoSize.height)
                    .shadow(color: logoColor.opacity(glow.opacity), radius: glow.radius)
                    .shadow(color: logoColor.opacity(glow.opacity * 0.6), radius: glow.radius * 2)
                    .scaleEffect(punchScale)
                    .offset(x: state.position.x, y: state.position.y)

                CornerCelebrationView(state: state)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .ignoresSafeArea()
        }
    }

    private func celebrationElapsed(now: TimeInterval) -> Double? {
        guard let start = state.celebrationStartedAt else { return nil }
        let t = now - start
        guard t >= 0, t < celebrationDuration else { return nil }
        return t
    }

    private func logoPunchScale(elapsed: Double?) -> CGFloat {
        guard let t = elapsed else { return 1 }
        if t < 0.12 {
            let p = t / 0.12
            return 1.0 + CGFloat(p) * 0.7
        }
        if t < 0.30 {
            let p = (t - 0.12) / 0.18
            return 1.7 - CGFloat(p) * 0.7
        }
        return 1
    }

    private func currentLogoColor(elapsed: Double?) -> Color {
        guard let t = elapsed else { return state.color }
        let hue = (t * 1.6).truncatingRemainder(dividingBy: 1.0)
        return Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }

    private func currentGlow(elapsed: Double?) -> (radius: CGFloat, opacity: Double) {
        guard let t = elapsed else { return (0, 0) }
        let fade: Double
        if t < 0.3 {
            fade = 1.0
        } else {
            fade = max(0, 1 - (t - 0.3) / (celebrationDuration - 0.3))
        }
        return (radius: 32, opacity: fade)
    }
}
