import SwiftUI
import QuartzCore
import Observation

@Observable
@MainActor
final class DVDState {
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var cornerHits: Int = 0
    var wallBounces: Int = 0
    var celebrationStartedAt: TimeInterval?

    var logoWidth: CGFloat = 240 {
        didSet { clampPosition() }
    }
    var logoSize: CGSize { CGSize(width: logoWidth, height: logoWidth * 0.5) }

    var speed: CGFloat = 280 {
        didSet { applySpeed(oldValue: oldValue) }
    }

    var screenSize: CGSize

    var celebrationsEnabled: Bool = true

    var mainText: String = "BNC"
    var subText: String = "LOGO"

    private var lastTickAt: TimeInterval?

    private static let palette: [Color] = [
        .yellow, .cyan, .pink, .green, .orange, .purple, .red,
        Color(red: 0.4, green: 0.8, blue: 1.0),
        Color(red: 1.0, green: 0.4, blue: 0.7),
        Color(red: 0.6, green: 1.0, blue: 0.4),
    ]

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let w: CGFloat = 240
        let h: CGFloat = 120
        let maxX = max(1, screenSize.width - w)
        let maxY = max(1, screenSize.height - h)
        self.position = CGPoint(
            x: .random(in: 40...max(41, maxX - 40)),
            y: .random(in: 40...max(41, maxY - 40))
        )
        let speed: CGFloat = 280
        let angle = CGFloat.random(in: 0.6...0.9)
        let signX: CGFloat = Bool.random() ? 1 : -1
        let signY: CGFloat = Bool.random() ? 1 : -1
        self.velocity = CGVector(
            dx: signX * speed * cos(angle),
            dy: signY * speed * sin(angle)
        )
        self.color = Self.palette.randomElement() ?? .yellow
    }

    func tick(now: TimeInterval) {
        let dt: CGFloat
        if let last = lastTickAt {
            dt = CGFloat(min(now - last, 1.0 / 30.0))
        } else {
            dt = 1.0 / 60.0
        }
        lastTickAt = now

        let w = logoSize.width
        let h = logoSize.height
        let sw = screenSize.width
        let sh = screenSize.height

        var x = position.x + velocity.dx * dt
        var y = position.y + velocity.dy * dt

        var bouncedX = false
        var bouncedY = false

        if x <= 0 {
            x = 0
            velocity.dx = abs(velocity.dx)
            bouncedX = true
        } else if x + w >= sw {
            x = sw - w
            velocity.dx = -abs(velocity.dx)
            bouncedX = true
        }

        if y <= 0 {
            y = 0
            velocity.dy = abs(velocity.dy)
            bouncedY = true
        } else if y + h >= sh {
            y = sh - h
            velocity.dy = -abs(velocity.dy)
            bouncedY = true
        }

        position = CGPoint(x: x, y: y)

        if bouncedX || bouncedY {
            wallBounces += 1
            cycleColor()
        }

        if bouncedX && bouncedY {
            triggerCornerHit(now: now)
        }
    }

    private func triggerCornerHit(now: TimeInterval) {
        cornerHits += 1
        NSLog("DVDBouncer: CORNER HIT! count=\(cornerHits)")
        if celebrationsEnabled {
            celebrationStartedAt = now
            color = Color(red: 1.0, green: 0.85, blue: 0.1)
            Audio.shared.celebrate()
        }
    }

    /// デバッグ用: トグル設定に関わらず演出を強制発動。
    func triggerCelebrationOnly() {
        cornerHits += 1
        celebrationStartedAt = CACurrentMediaTime()
        color = Color(red: 1.0, green: 0.85, blue: 0.1)
        Audio.shared.celebrate()
    }

    /// ロゴを 4 角のいずれかへ確実に向かう軌道に強制セット（デバッグ用）。
    /// 配置位置から左上角まで X/Y の距離が等しくなる位置に置き、速度ベクトルもその比率にすることで、tick の同フレーム判定で確実に角ヒットを起こす。
    func aimAtCorner() {
        let w = logoSize.width
        let h = logoSize.height
        let sw = screenSize.width
        let sh = screenSize.height
        guard sw > w * 2, sh > h * 2 else { return }

        let corners: [(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat)] = [
            (180, 180, -1, -1),
            (sw - w - 180, 180, 1, -1),
            (180, sh - h - 180, -1, 1),
            (sw - w - 180, sh - h - 180, 1, 1),
        ]
        let target = corners.randomElement()!
        position = CGPoint(x: target.x, y: target.y)
        let unit = sqrt(0.5)
        velocity = CGVector(dx: target.dx * speed * unit, dy: target.dy * speed * unit)
        lastTickAt = nil
    }

    private func cycleColor() {
        let candidates = Self.palette.filter { $0 != color }
        if let next = candidates.randomElement() {
            color = next
        }
    }

    private func clampPosition() {
        let w = logoSize.width
        let h = logoSize.height
        position.x = min(max(0, position.x), max(0, screenSize.width - w))
        position.y = min(max(0, position.y), max(0, screenSize.height - h))
    }

    /// 現在の位置・速度・サイズから、最初の角ヒットまでに必要な「壁ヒット回数」を予測する。
    /// 連続時間で次の壁ヒット時刻を解析的に進め、X と Y の壁ヒットが 1 フレーム以内に揃ったら角ヒット扱い（tick の判定基準と整合）。
    /// 上限内に角に当たらなければ nil を返す（速度比が悪いと角に永久に当たらないことがある）。
    func bouncesUntilCorner(maxBounces: Int = 12_000) -> Int? {
        let w = logoSize.width
        let h = logoSize.height
        let sw = screenSize.width
        let sh = screenSize.height
        guard sw > w, sh > h else { return nil }
        guard velocity.dx != 0, velocity.dy != 0 else { return nil }

        var x = position.x
        var y = position.y
        var vx = velocity.dx
        var vy = velocity.dy
        let frameTime: CGFloat = 1.0 / 60.0

        for n in 1...maxBounces {
            let distX = vx > 0 ? (sw - w - x) : x
            let distY = vy > 0 ? (sh - h - y) : y
            let tx = max(0, distX) / abs(vx)
            let ty = max(0, distY) / abs(vy)
            let t = min(tx, ty)

            x += vx * t
            y += vy * t

            let bouncedX = (tx - t) <= frameTime
            let bouncedY = (ty - t) <= frameTime

            if bouncedX && bouncedY {
                return n
            }
            if bouncedX { vx = -vx }
            if bouncedY { vy = -vy }
        }
        return nil
    }

    private func applySpeed(oldValue: CGFloat) {
        let current = hypot(velocity.dx, velocity.dy)
        guard current > 0 else {
            velocity = CGVector(dx: speed * 0.8, dy: speed * 0.6)
            return
        }
        let scale = speed / current
        velocity.dx *= scale
        velocity.dy *= scale
    }
}
