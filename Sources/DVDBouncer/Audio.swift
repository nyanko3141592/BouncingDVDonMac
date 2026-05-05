import AppKit

@MainActor
final class Audio {
    static let shared = Audio()

    private init() {}

    func celebrate() {
        playSystem("Hero")
        playSystem("Glass")
        playSystem("Funk")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            self?.playSystem("Glass")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.playSystem("Tink")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { [weak self] in
            self?.playSystem("Glass")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) { [weak self] in
            self?.playSystem("Tink")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.playSystem("Submarine")
        }
    }

    private func playSystem(_ name: String) {
        guard let sound = NSSound(named: NSSound.Name(name))?.copy() as? NSSound else { return }
        sound.volume = 1.0
        sound.play()
    }
}
