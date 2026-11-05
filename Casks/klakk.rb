cask "klakk" do
  version "1.4.2,24"
  sha256 "625608969133c6930cbdd3d52082c58104e189f04832b9834dc186e360f0b601"

  url "https://downloads.tryklakk.com/Klakk-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Klakk"
  desc "Keyboard sounds while typing"
  homepage "https://tryklakk.com/en/"

  livecheck do
    url "https://github.com/levindong2026/klakk-downloads"
    regex(/^Klakk-(\d+(?:\.\d+)+)-(\d+)(?:-r(\d{8}\.\d+))?\.dmg$/i)
    strategy :github_releases do |json, regex|
      json.flat_map do |release|
        next [] if release["draft"] || release["prerelease"]

        release.fetch("assets", []).filter_map do |asset|
          next if asset["state"] != "uploaded"

          match = asset["name"]&.match(regex)
          next unless match

          match.captures.compact.join(",")
        end
      end
    end
  end

  depends_on macos: :sonoma

  # Preserve the existing installation path while matching the revised bundle name.
  app "klakk.app", target: "Klakk.app"

  caveats <<~EOS
    Klakk needs Input Monitoring permission to react to keyboard events in other apps.
    After installing, open Klakk and follow its permission prompt.
    The full-featured trial lasts 3 days. Continued use requires a separate Mac license.
    See https://tryklakk.com/en/privacy/ and https://tryklakk.com/en/terms/.
  EOS
end
