# Exercise the actual cask strategy block without installing its app artifact.
class ReleaseCheckCapture
  attr_reader :matcher, :source_url

  def url(value)
    @source_url = value
  end

  def strategy(value, &block)
    raise "Unexpected strategy" unless value == :json

    @matcher = block
  end
end

class CaskCapture
  attr_reader :release_check

  def version(value = nil)
    @version = value if value
    parts = Struct.new(:first, :second, :third).new(*@version.split(","))
    Struct.new(:csv).new(parts)
  end

  def livecheck(&block)
    @release_check = ReleaseCheckCapture.new
    @release_check.instance_eval(&block)
  end

  def method_missing(_method, *_args); end

  def respond_to_missing?(_method, _private = false)
    true
  end
end

capture = CaskCapture.new
context = Object.new
context.define_singleton_method(:cask) { |_name, &block| capture.instance_eval(&block) }
context.instance_eval(File.read("Casks/klakk.rb"), "Casks/klakk.rb")
check = capture.release_check

raise "Unexpected metadata URL" unless check.source_url == "https://tryklakk.com/api/desktop-release.json"

OFFICIAL_DMG = "https://tryklakk.com/download/klakk.dmg".freeze

def desktop_feed(version: "1.4.4", build: 26, url: OFFICIAL_DMG)
  {
    "schema_version" => 1,
    "mac" => { "version" => version, "build" => build, "download_url" => url },
    "windows" => { "version" => "9.9.9", "download_url" => "https://tryklakk.com/download/klakk-windows.exe" },
  }
end

cases = {
  "current website Mac version and build" => [desktop_feed, "1.4.4,26"],
  "separately newer Windows version is ignored" => [desktop_feed(version: "1.4.3", build: 25), "1.4.3,25"],
  "new version and build remain distinguishable" => [desktop_feed(version: "10.4.5", build: 31), "10.4.5,31"],
  "newer build of the same app version" => [desktop_feed(build: 27), "1.4.4,27"],
  "Windows-only feed cannot supply Mac version" => [desktop_feed.merge("mac" => nil), nil],
  "Mac absent during publication" => [desktop_feed.reject { |key, _| key == "mac" }, nil],
  "unknown schema" => [desktop_feed.merge("schema_version" => 2), nil],
  "schema must be integer" => [desktop_feed.merge("schema_version" => 1.0), nil],
  "missing schema" => [desktop_feed.reject { |key, _| key == "schema_version" }, nil],
  "malformed input is unavailable" => [nil, nil],
  "legacy GitHub asset array is unavailable" => [[{ "assets" => [{ "name" => "Klakk-9.9.9-99.dmg" }] }], nil],
  "malformed Mac row" => [desktop_feed.merge("mac" => "1.4.4"), nil],
  "missing Mac version" => [desktop_feed(version: nil), nil],
  "malformed Mac version" => [desktop_feed(version: "1..4.4"), nil],
  "prerelease version rejected" => [desktop_feed(version: "1.4.5-beta"), nil],
  "missing Mac build" => [desktop_feed(build: nil), nil],
  "build string rejected" => [desktop_feed(build: "26"), nil],
  "float build rejected" => [desktop_feed(build: 26.0), nil],
  "negative build rejected" => [desktop_feed(build: -1), nil],
  "zero build rejected" => [desktop_feed(build: 0), nil],
  "Mac ZIP excluded" => [desktop_feed(url: "https://tryklakk.com/download/klakk.zip"), nil],
  "Mac App Store excluded" => [desktop_feed(url: "https://tryklakk.com/appstore/klakk"), nil],
  "foreign download URL rejected" => [desktop_feed(url: "https://unknown.invalid/download/klakk.dmg"), nil],
  "HTTP download URL rejected" => [desktop_feed(url: "http://tryklakk.com/download/klakk.dmg"), nil],
  "QA or draft download path rejected" => [desktop_feed(url: "https://tryklakk.com/download/qa-klakk.dmg"), nil],
  "query on stable URL rejected" => [desktop_feed(url: "#{OFFICIAL_DMG}?qa=1"), nil],
}

cases.each do |name, (input, expected)|
  actual = check.matcher.call(input)
  raise "#{name}: #{actual.inspect} != #{expected.inspect}" unless actual == expected

  puts "PASS: #{name}"
end

if ARGV[0]
  require "json"
  website = JSON.parse(File.read(ARGV.fetch(0)))
  expected = ARGV.fetch(1)
  raise "Official feed mismatch" unless check.matcher.call(website) == expected

  puts "PASS: recorded first-party website response"
end
