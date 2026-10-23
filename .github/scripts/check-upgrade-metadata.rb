# Exercise Homebrew's real version and outdated logic with simulated receipts.
# This does not download, install, launch or upgrade the application.
require "cask/cask_loader"
require "version"

cask = Cask::CaskLoader.load(Pathname.new("Casks/klakk.rb").expand_path)
expected = "1.4.1,23,20261011.1"
raise "Unexpected candidate version" unless cask.version.to_s == expected
raise "Unexpected revision URL" unless cask.url.to_s ==
                                       "https://downloads.tryklakk.com/Klakk-1.4.1-23-r20261011.1.dmg"
raise "Unexpected revision checksum" unless cask.sha256.to_s ==
                                            "71006389accd8deda13a5a50fcf0ae4263d70a0d9f0bc9f82218906cd313aedc"

app = cask.artifacts.find { |artifact| artifact.is_a?(Cask::Artifact::App) }
raise "Expected one app artifact" unless app
raise "Revision bundle name differs" unless app.source.basename.to_s == "klakk.app"
raise "Existing installation target changed" unless app.target.basename.to_s == "Klakk.app"
puts "PASS: revised bundle maps to the existing installation target (metadata only)"

comparisons = {
  "revision follows original package" => ["1.4.1,23", expected],
  "later revision follows current" => [expected, "1.4.1,23,20261011.2"],
  "multi-digit revision is numerically ordered" => ["1.4.1,23,20261011.2", "1.4.1,23,20261011.10"],
  "later revision date follows current" => [expected, "1.4.1,23,20261012.1"],
  "new build outranks internal revision" => [expected, "1.4.1,24"],
  "new app version outranks internal revision" => [expected, "1.4.2,1"],
}
comparisons.each do |name, (older, newer)|
  raise "#{name}: Homebrew version comparison failed" unless Version.new(older) < Version.new(newer)

  puts "PASS: #{name}"
end

{
  "old package receipt is outdated" => ["1.4.1,23", true],
  "current package receipt is not outdated" => [expected, false],
  "absent receipt is not an installed upgrade" => [nil, false],
}.each do |name, (installed, expected_outdated)|
  cask.define_singleton_method(:installed_version) { installed }
  raise "#{name}: Homebrew outdated check failed" unless cask.outdated? == expected_outdated

  puts "PASS: #{name} (simulated receipt, no installation)"
end
puts "Homebrew metadata checks passed; no application was downloaded, installed or launched."
