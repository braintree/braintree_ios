require 'tempfile'
require 'fileutils'
require 'shellwords'
require 'bundler'
Bundler.require
HighLine.color_scheme = HighLine::SampleColorScheme.new

task :default => %w[sanity_checks spec]

desc "Run default set of tasks"
task :spec => %w[spec:all]

desc "Run internal release process, pushing to internal GitHub Enterprise only"
task :release => %w[release:assumptions sanity_checks release:check_working_directory release:bump_version release:lint_podspec release:tag release:push_private]

desc "Publish code and pod to public github.com"
task :publish => %w[publish:push publish:push_pod docs_internal docs_external]

SEMVER = /\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?/
PODSPEC = "Braintree.podspec"
BRAINTREE_VERSION_FILE = "BraintreeCore/Braintree-Version.h"
PAYPAL_ONE_TOUCH_VERSION_FILE = "BraintreePayPal/PayPalUtils/Public/PPOTVersion.h"
DEMO_PLIST = "Demo/Supporting Files/Braintree-Demo-Info.plist"
FRAMEWORKS_PLIST = "BraintreeCore/Info.plist"
PUBLIC_REMOTE_NAME = "public"

class << self
  def run cmd
    say(HighLine.color("$ #{cmd}", :debug))
    File.popen(cmd) { |file|
      if block_given?
        result = ''
        result << file.gets until file.eof?
        yield result
      else
        puts file.gets until file.eof?
      end
    }
    $? == 0
  end

  def run! cmd
    run(cmd) or fail("Command failed with non-zero exit status #{$?}:\n$ #{cmd}")
  end

  def current_version
    File.read(PODSPEC)[SEMVER]
  end

  def current_version_with_sha
    %x{git describe}.strip
  end

  def current_branch
    %x{git rev-parse --abbrev-ref HEAD}.strip
  end

  def xcodebuild(scheme, command, configuration, ios_version, options={})
    default_options = {
      :build_settings => {}
    }
    ios_version_specifier = ",OS=#{ios_version}" if !ios_version.nil?
    options = default_options.merge(options)
    build_settings = options[:build_settings].map{|k,v| "#{k}='#{v}'"}.join(" ")
    return "set -o pipefail && xcodebuild -workspace 'Braintree.xcworkspace' -sdk 'iphonesimulator' -configuration '#{configuration}' -scheme '#{scheme}' -destination 'name=iPhone 6,platform=iOS Simulator#{ios_version_specifier}' #{build_settings} #{command} | xcpretty -c -r junit"
  end

end

namespace :spec do
  def run_test_scheme! scheme, ios_version = nil
    run! xcodebuild(scheme, 'test', 'Release', ios_version)
  end

  desc 'Run unit tests'
  task :unit, [:ios_version] do |t, args|
    if args[:ios_version]
      run_test_scheme! 'UnitTests', args[:ios_version]
    else
      run_test_scheme! 'UnitTests'
    end
  end

  desc 'Run UI tests'
  task :ui do
    run_test_scheme! 'UITests'
  end

  namespace :api do
    def with_https_server &block
      begin
        pid = Process.spawn('ruby ./IntegrationTests/Braintree-API-Integration-Specs/SSL/https_server.rb')
        puts "Started server (#{pid})"
        yield
        puts "Killing server (#{pid})"
      ensure
        Process.kill("INT", pid)
      end
    end

    desc 'Run integration tests'
    task :integration do
      with_https_server do
        run! xcodebuild('IntegrationTests', 'test', 'Release', nil, :build_settings => {'GCC_PREPROCESSOR_DEFINITIONS' => '$GCC_PREPROCESSOR_DEFINITIONS RUN_SSL_PINNING_SPECS=1'})
      end
    end
  end

  desc 'Run all spec schemes'
  task :all => %w[spec:unit spec:api:integration spec:ui]
end

namespace :demo do
  desc 'Verify that the demo app builds successfully'
  task :build do
    run! xcodebuild('Demo', 'build', 'Release', nil)
  end
end

desc 'Run Carthage update'
namespace :carthage do
  def generate_cartfile
    run! 'mv Cartfile Cartfile.backup'
    File.write("./Cartfile", "git \"file://#{Dir.pwd}\" \"#{current_branch}\"")
  end

  task :clean do
    run! 'rm -rf Carthage && rm Cartfile && rm Cartfile.resolved && rm -rf ~/Library/Developers/Xcode/DerivedData'
    run! 'mv Cartfile.backup Cartfile'
  end

  task :test do
    generate_cartfile
    run! "carthage update"
    run! "xcodebuild -project 'Demo/CarthageTest/CarthageTest.xcodeproj' -scheme 'CarthageTest' clean build"
  end
end

desc 'Run all sanity checks'
task :sanity_checks => %w[sanity_checks:pending_specs sanity_checks:build_demo sanity_checks:carthage_test]

namespace :sanity_checks do
  desc 'Check for pending tests'
  task :pending_specs do
    begin
      run! "which -s ack"
    rescue => e
      puts
      say(HighLine.color("Please install ack before running", :red, :bold))
      puts
      raise
    end

    # ack returns 1 if no match is found, which is our success case
    run! "! ack 'fit\\(|fdescribe\\(' Specs" or fail "Please do not commit pending specs."
  end

  desc 'Verify that all demo apps Build successfully'
  task :build_demo => 'demo:build'

  desc 'Verify that Carthage builds successfully'
  task :carthage_test => %w[carthage:test carthage:clean]
end

namespace :release do
  desc "Print out pre-release checklist"
  task :assumptions do
    say "Release Assumptions"
    say "* [ ] You are on the branch and commit you want to release."
    say "* [ ] You have already merged hotfixes and pulled changes."
    say "* [ ] You have already reviewed the diff between the current release and the last tag, noting breaking changes in the semver and CHANGELOG."
    say "* [ ] Tests (rake spec) are passing, manual verifications complete."
    say "* [ ] Email is composed and ready to send to braintree-sdk-announce@googlegroups.com"

    abort(1) unless ask "Ready to release? Press any key to continue. "
  end

  desc "Check that working directory is clean"
  task :check_working_directory do
    run! "echo 'Checking for uncommitted changes' && git diff --exit-code"
  end

  desc "Bump version in Podspec"
  task :bump_version do
    say "Current version in Podspec: #{current_version}"
    n = 10
    say "Previous #{n} versions in Git:"
    run "git tag -l | tail -n #{n}"
    version = ask("What version are you releasing?") { |q| q.validate = /\A#{SEMVER}\Z/ }

    podspec = File.read(PODSPEC)
    podspec.gsub!(/(s\.version\s*=\s*)"#{SEMVER}"/, "\\1\"#{version}\"")
    File.open(PODSPEC, "w") { |f| f.puts podspec }

    version_header = File.read(BRAINTREE_VERSION_FILE)
    version_header.gsub!(SEMVER, version)
    File.open(BRAINTREE_VERSION_FILE, "w") { |f| f.puts version_header }

    version_header = File.read(PAYPAL_ONE_TOUCH_VERSION_FILE)
    version_header.gsub!(SEMVER, version)
    File.open(PAYPAL_ONE_TOUCH_VERSION_FILE, "w") { |f| f.puts version_header }

    [DEMO_PLIST, FRAMEWORKS_PLIST].each do |plist|
      run! "plutil -replace CFBundleVersion -string #{current_version} -- '#{plist}'"
      run! "plutil -replace CFBundleShortVersionString -string #{current_version} -- '#{plist}'"
    end
    run "git commit -m 'Bump pod version to #{version}' -- #{PODSPEC} Podfile.lock '#{DEMO_PLIST}' '#{FRAMEWORKS_PLIST}' #{BRAINTREE_VERSION_FILE} #{PAYPAL_ONE_TOUCH_VERSION_FILE}"
  end

  desc  "Test."
  task :test => 'spec:all'

  desc  "Lint podspec."
  task :lint_podspec do
    run! "pod lib lint Braintree.podspec --allow-warnings"
  end

  desc  "Tag."
  task :tag do
    run! "git tag #{current_version} -a -m 'Release #{current_version}'"
  end

  desc  "Push tag to ghe."
  task :push_private do
    run! "git push origin HEAD #{current_version}"
  end

end

namespace :publish do

  desc  "Push code and tag to github.com"
  task :push do
    run! "git push #{PUBLIC_REMOTE_NAME} HEAD #{current_version}"
  end

  desc  "Pod push."
  task :push_pod do
    run! "pod trunk push --allow-warnings Braintree.podspec"
  end

end

namespace :gen do
  task :strings do
    ["Drop-In", "UI"].each do |subspec|
      run! "genstrings -o Braintree/#{subspec}/Localization/en.lproj Braintree/#{subspec}/**/*.m && " +
           "iconv -f utf-16 -t utf-8 Braintree/#{subspec}/Localization/en.lproj/Localizable.strings > Braintree/#{subspec}/Localization/en.lproj/#{subspec}.strings && " +
           "rm -f Braintree/#{subspec}/Localization/en.lproj/Localizable.strings"
    end
  end
end

def jazzy_command
  %W[jazzy
      --objc
      --author Braintree
      --author_url http://braintreepayments.com
      --github_url https://github.com/braintree/braintree_ios
      --github-file-prefix https://github.com/braintree/braintree_ios/tree/#{current_version}
      --sdk iphonesimulator
      --module-version #{current_version}
      --output docs_output
      --xcodebuild-arguments --objc,Docs/Braintree-Umbrella-Header.h,--,-x,objective-c,-isysroot,$(xcrun --show-sdk-path),-I,$(pwd)
      --min-acl internal
      --theme fullwidth
      --module Braintree
  ].join(' ')
end

desc "Generate documentation via jazzy and push to GHE"
task :docs_internal => %w[docs:generate docs:publish docs:internal docs:clean]

desc "Generate documentation via jazzy and push to GH"
task :docs_external => %w[docs:generate docs:publish docs:external docs:clean]

namespace :docs do

  desc "Generate docs with jazzy"
  task :generate do
    run! 'rm -rf docs_output'
    run(jazzy_command)
    puts "Generated HTML documentation at docs_output"
  end

  task :publish do
    run 'git branch -D gh-pages'
    run! 'git add docs_output'
    run! 'git commit -m "Publish docs to github pages"'
    puts "Generating git subtree, this will take a moment..."
    run! 'git subtree split --prefix docs_output -b gh-pages'
  end

  task:internal do
    run! 'git push -f origin gh-pages:gh-pages'
  end

  task:external do
    run! 'git push -f public gh-pages:gh-pages'
  end

  task :clean do
    run! 'git reset HEAD~'
    run! 'git branch -D gh-pages'
    puts "Published docs to gh-pages branch"
    run! 'rm -rf docs_output'
  end

end
