import SwiftUI
import QuartzCore

private struct Confetti: Identifiable {
    let id: Int
    let velocity: CGVector
    let initialRotation: Double
    let rotationSpeed: Double
    let color: Color
    let size: CGSize
    let isRect: Bool
    let originOffset: CGVector
}

private let confettiPalette: [Color] = [
    .yellow, .orange, .pink, .red, .cyan, .green, .purple, .white,
    Color(red: 1.0, green: 0.85, blue: 0.1),
    Color(red: 0.4, green: 0.9, blue: 1.0),
]

private func makeConfetti(count: Int = 110) -> [Confetti] {
    (0..<count).map { i in
        let angle = Double.random(in: 0..<2 * .pi)
        let speed = CGFloat.random(in: 480...1100)
        return Confetti(
            id: i,
            velocity: CGVector(
                dx: speed * cos(angle),
                dy: speed * sin(angle) - CGFloat.random(in: 200...500)
            ),
            initialRotation: Double.random(in: 0..<2 * .pi),
            rotationSpeed: Double.random(in: -10...10),
            color: confettiPalette.randomElement() ?? .white,
            size: CGSize(
                width: CGFloat.random(in: 9...20),
                height: CGFloat.random(in: 5...14)
            ),
            isRect: Bool.random(),
            originOffset: CGVector(
                dx: CGFloat.random(in: -40...40),
                dy: CGFloat.random(in: -40...40)
            )
        )
    }
}

struct CornerCelebrationView: View {
    @Bindable var state: DVDState

    @State private var particles: [Confetti] = []
    @State private var lastSeenStart: TimeInterval = -1

    private let totalDuration: Double = 2.4
    private let gravity: CGFloat = 1400

    var body: some View {
        TimelineView(.animation) { _ in
            let elapsed = currentElapsed()
            ZStack {
                if elapsed >= 0 && elapsed < totalDuration {
                    flashLayer(t: elapsed)
                    radialBurst(t: elapsed)
                    confettiCanvas(t: elapsed)
                    bigText(t: elapsed)
                    hitCounterChip(t: elapsed)
                }
            }
            .ignoresSafeArea()
            .onChange(of: state.celebrationStartedAt) { _, newValue in
                if let v = newValue, v != lastSeenStart {
                    lastSeenStart = v
                    particles = makeConfetti()
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func currentElapsed() -> Double {
        guard let start = state.celebrationStartedAt else { return .infinity }
        return CACurrentMediaTime() - start
    }

    private func flashLayer(t: Double) -> some View {
        let opacity = max(0, 0.7 - t * 1.4)
        return Color.white.opacity(opacity)
    }

    private func radialBurst(t: Double) -> some View {
        let progress = min(1, t / 0.6)
        let size = 80 + progress * 1400
        let opacity = max(0, 0.6 - t * 1.0)
        return Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [.yellow, .orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: max(2, 18 - progress * 16)
            )
            .frame(width: size, height: size)
            .opacity(opacity)
            .blendMode(.plusLighter)
    }

    private func confettiCanvas(t: Double) -> some View {
        Canvas { gctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            for p in particles {
                let x = cx + p.originOffset.dx + p.velocity.dx * CGFloat(t)
                let y = cy + p.originOffset.dy + p.velocity.dy * CGFloat(t)
                    + 0.5 * gravity * CGFloat(t * t)
                if y > size.height + 60 { continue }
                var ctx = gctx
                ctx.translateBy(x: x, y: y)
                ctx.rotate(by: .radians(p.initialRotation + p.rotationSpeed * t))
                let rect = CGRect(
                    x: -p.size.width / 2,
                    y: -p.size.height / 2,
                    width: p.size.width,
                    height: p.size.height
                )
                let path = p.isRect ? Path(rect) : Path(ellipseIn: rect)
                ctx.fill(path, with: .color(p.color))
            }
        }
    }

    private func bigText(t: Double) -> some View {
        let scale: Double
        let opacity: Double
        if t < 0.18 {
            let p = t / 0.18
            scale = 0.3 + p * 1.1   // 0.3 -> 1.4
            opacity = p
        } else if t < 0.32 {
            let p = (t - 0.18) / 0.14
            scale = 1.4 - p * 0.4   // 1.4 -> 1.0
            opacity = 1
        } else if t < 1.6 {
            scale = 1.0
            opacity = 1
        } else {
            let p = min(1, (t - 1.6) / 0.7)
            scale = 1.0 + p * 0.15
            opacity = max(0, 1 - p)
        }

        return VStack(spacing: 16) {
            Text("CORNER HIT!!!")
                .font(.system(size: 130, weight: .black, design: .rounded))
                .italic()
                .tracking(2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.4),
                            .orange,
                            Color(red: 1.0, green: 0.2, blue: 0.5),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.55), radius: 12, x: 0, y: 6)
                .shadow(color: Color.yellow.opacity(0.8), radius: 30)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }

    private func hitCounterChip(t: Double) -> some View {
        let opacity: Double
        let yOffset: CGFloat
        if t < 0.25 {
            let p = t / 0.25
            opacity = p
            yOffset = 60 - CGFloat(p) * 40
        } else if t < 1.7 {
            opacity = 1
            yOffset = 20
        } else {
            let p = min(1, (t - 1.7) / 0.7)
            opacity = max(0, 1 - p)
            yOffset = 20
        }

        return Text("HIT #\(state.cornerHits)")
            .font(.system(size: 38, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(.black.opacity(0.55))
            )
            .overlay(
                Capsule().stroke(
                    LinearGradient(colors: [.yellow, .pink], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 3
                )
            )
            .shadow(color: .yellow.opacity(0.7), radius: 20)
            .offset(y: 130 + yOffset)
            .opacity(opacity)
    }
}
