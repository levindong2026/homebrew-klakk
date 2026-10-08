cask "klakk" do
  version "1.4.1,23"
  sha256 "23c6b838f4e17e2ccddba1eb91927d0fe714403abcc512fca0545a013f5dfa51"

  url "https://downloads.tryklakk.com/Klakk-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Klakk"
  desc "Keyboard sounds while typing"
  homepage "https://tryklakk.com/en/"

  livecheck do
    skip "Updated by Klakk after the published installer has been verified"
  end

  depends_on macos: :sonoma

  app "Klakk.app"

  caveats <<~EOS
    Klakk needs Input Monitoring permission to react to keyboard events in other apps.
    After installing, open Klakk and follow its permission prompt.
    The full-featured trial lasts 3 days. Continued use requires a separate Mac license.
    See https://tryklakk.com/en/privacy/ and https://tryklakk.com/en/terms/.
  EOS
end
