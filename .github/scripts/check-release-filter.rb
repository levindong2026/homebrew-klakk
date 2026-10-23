# Exercise the actual cask strategy block without installing its app artifact.
class ReleaseCheckCapture
  attr_reader :matcher

  def url(_value); end

  def regex(value = nil)
    @regex = value if value
    @regex
  end

  def strategy(value, &block)
    raise "Unexpected strategy" unless value == :github_releases

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

def release(name, draft: false, prerelease: false, state: "uploaded")
  { "draft" => draft, "prerelease" => prerelease,
    "assets" => [{ "name" => name, "state" => state }] }
end

cases = {
  "Mac version includes its build" => [[release("Klakk-1.4.1-23.dmg")], ["1.4.1,23"]],
  "Windows-only release cannot replace Mac" => [[release("Klakk-9.9.9-Windows-Setup.exe")], []],
  "draft Mac excluded" => [[release("Klakk-9.9.9-99.dmg", draft: true)], []],
  "prerelease Mac excluded" => [[release("Klakk-9.9.9-99.dmg", prerelease: true)], []],
  "unfinished asset excluded" => [[release("Klakk-9.9.9-99.dmg", state: "new")], []],
  "missing assets do not invent a version" => [[{ "draft" => false, "prerelease" => false }], []],
  "new build remains distinguishable" => [[release("Klakk-1.4.1-24.dmg")], ["1.4.1,24"]],
  "internal revision remains distinguishable" => [[release("Klakk-1.4.1-23-r20261011.1.dmg")], ["1.4.1,23,20261011.1"]],
  "old and current revision can coexist" => [[release("Klakk-1.4.1-23.dmg"), release("Klakk-1.4.1-23-r20261011.1.dmg")], ["1.4.1,23", "1.4.1,23,20261011.1"]],
  "draft revision excluded" => [[release("Klakk-1.4.1-23-r20261011.1.dmg", draft: true)], []],
  "prerelease revision excluded" => [[release("Klakk-1.4.1-23-r20261011.1.dmg", prerelease: true)], []],
  "unfinished revision excluded" => [[release("Klakk-1.4.1-23-r20261011.1.dmg", state: "new")], []],
  "revision ZIP is not a DMG" => [[release("Klakk-1.4.1-23-r20261011.1.zip")], []],
  "Windows revision excluded" => [[release("Klakk-1.4.1-Windows-Setup-r20261011.1.exe")], []],
  "QA prefix excluded" => [[release("QA-Klakk-1.4.1-23-r20261011.1.dmg")], []],
  "QA suffix excluded" => [[release("Klakk-1.4.1-23-r20261011.1-qa.dmg")], []],
  "malformed revision excluded" => [[release("Klakk-1.4.1-23-r20261011.dmg")], []],
  "store artifact excluded" => [[release("Klakk-AppStore-1.3.8-23.dmg")], []],
}

cases.each do |name, (input, expected)|
  actual = check.matcher.call(input, check.regex)
  raise "#{name}: #{actual.inspect} != #{expected.inspect}" unless actual == expected

  puts "PASS: #{name}"
end
