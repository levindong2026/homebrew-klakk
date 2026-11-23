cask "klakk" do
  version "1.4.4,26"
  sha256 "8dc69ccda0687967c93f9ed05ea4fe39db3b4f303308598cdecf9ea0da5d6729"

  url "https://downloads.tryklakk.com/Klakk-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Klakk"
  desc "Keyboard sounds while typing"
  homepage "https://tryklakk.com/en/"

  livecheck do
    url "https://tryklakk.com/api/desktop-release.json"
    strategy :json do |json|
      next unless json.is_a?(Hash) && json["schema_version"].eql?(1)

      mac = json["mac"]
      next unless mac.is_a?(Hash) && mac["download_url"] == "https://tryklakk.com/download/klakk.dmg"

      version = mac["version"]
      build = mac["build"]
      next unless version.is_a?(String) && version.match?(/\A[0-9]+(?:\.[0-9]+)+\z/)
      next unless build.is_a?(Integer) && build.positive?

      "#{version},#{build}"
    end
  end

  depends_on macos: :sonoma

  # Preserve the existing installation path while matching the revised bundle name.
  app "Klakk.app", target: "Klakk.app"

  caveats <<~EOS
    Klakk needs Input Monitoring permission to react to keyboard events in other apps.
    After installing, open Klakk and follow its permission prompt.
    The full-featured trial lasts 3 days. Continued use requires a separate Mac license.
    See https://tryklakk.com/en/privacy/ and https://tryklakk.com/en/terms/.
  EOS
end
