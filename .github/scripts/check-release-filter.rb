require "json"

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
}

cases.each do |name, (input, expected)|
  actual = check.matcher.call(input, check.regex)
  raise "#{name}: #{actual.inspect} != #{expected.inspect}" unless actual == expected

  puts "PASS: #{name}"
end
