# Exercise Homebrew's real version and outdated logic with simulated receipts.
# This does not download, install, launch or upgrade the application.
require "cask/cask_loader"
require "version"

cask = Cask::CaskLoader.load(Pathname.new(ARGV.fetch(0)).expand_path)
expected = "1.4.4,26"
previous_website = "1.4.3,25"
previous = "1.4.1,23,20261011.1"
raise "Unexpected candidate version" unless cask.version.to_s == expected
expected_url = "https://downloads.tryklakk.com/Klakk-1.4.4-26.dmg"
raise "Unexpected candidate URL" unless cask.url.to_s == expected_url
expected_checksum = "8dc69ccda0687967c93f9ed05ea4fe39db3b4f303308598cdecf9ea0da5d6729"
raise "Unexpected candidate checksum" unless cask.sha256.to_s == expected_checksum

app = cask.artifacts.find { |artifact| artifact.is_a?(Cask::Artifact::App) }
raise "Expected one app artifact" unless app
raise "Unexpected app bundle source" unless app.source.basename.to_s == "Klakk.app"
raise "Existing installation target changed" unless app.target.basename.to_s == "Klakk.app"
puts "PASS: current bundle maps to the existing installation target (metadata only)"

comparisons = {
  "revision follows original package" => ["1.4.1,23", previous],
  "later internal revision follows prior revision" => [previous, "1.4.1,23,20261011.2"],
  "multi-digit revision is numerically ordered" => ["1.4.1,23,20261011.2", "1.4.1,23,20261011.10"],
  "later revision date follows prior revision" => [previous, "1.4.1,23,20261012.1"],
  "new build outranks internal revision" => [previous, "1.4.1,24"],
  "new app version outranks internal revision" => [previous, expected],
  "new website build follows 1.4.3" => [previous_website, expected],
}
comparisons.each do |name, (older, newer)|
  raise "#{name}: Homebrew version comparison failed" unless Version.new(older) < Version.new(newer)

  puts "PASS: #{name}"
end

{
  "old package receipt is outdated" => ["1.4.1,23", true],
  "prior revision receipt is outdated" => [previous, true],
  "prior website package receipt is outdated" => [previous_website, true],
  "current package receipt is not outdated" => [expected, false],
  "absent receipt is not an installed upgrade" => [nil, false],
}.each do |name, (installed, expected_outdated)|
  cask.define_singleton_method(:installed_version) { installed }
  raise "#{name}: Homebrew outdated check failed" unless cask.outdated? == expected_outdated

  puts "PASS: #{name} (simulated receipt, no installation)"
end
puts "Homebrew metadata checks passed; no application was downloaded, installed or launched."
