cask "bouncinglogo" do
  version "0.1.0"
  sha256 "REPLACE_WITH_DMG_SHA256"

  url "https://github.com/nyanko3141592/BouncingDVDonMac/releases/download/v#{version}/BouncingLogo-#{version}.dmg"
  name "BouncingLogo"
  desc "Generic bouncing logo overlay for macOS with corner-hit celebration"
  homepage "https://github.com/nyanko3141592/BouncingDVDonMac"

  depends_on macos: ">= :sonoma"
  depends_on arch: :arm64

  app "BouncingLogo.app"

  zap trash: [
    "~/Library/Preferences/com.nyanko.bouncinglogo.plist",
    "~/Library/Application Support/com.nyanko.bouncinglogo",
    "~/Library/Caches/com.nyanko.bouncinglogo",
  ]
end
