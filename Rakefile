require 'tempfile'
require 'fileutils'
require 'shellwords'
require 'bundler'
Bundler.require
HighLine.color_scheme = HighLine::SampleColorScheme.new

task :default => %w[sanity_checks spec]

desc "Run all test tasks"
task :spec => %w[spec:all]

desc "Run sanity checks; bump and tag new version"
task :release => %w[release:assumptions build_demo_apps release:check_working_directory release:bump_version release:lint_podspec carthage:create_frameworks carthage:create_xcframeworks carthage:remove_spm_test_app release:tag]

desc "Push tags, docs, and Pod"
task :publish => %w[carthage:restore_spm_test_app publish:push_private publish:push_public publish:push_pod publish:create_github_release docs_publish]

SEMVER = /\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?/
PODSPEC = "Braintree.podspec"
BRAINTREE_VERSION_FILE = "Sources/BraintreeCore/Braintree-Version.h"
DEMO_PLIST = "Demo/Application/Supporting Files/Braintree-Demo-Info.plist"
FRAMEWORKS_PLIST = "Sources/BraintreeCore/Info.plist"
PUBLIC_REMOTE_NAME = "origin"
GHE_REMOTE_NAME = "internal"

bt_modules = ["BraintreeAmericanExpress", "BraintreeApplePay", "BraintreeCard", "BraintreeCore", "BraintreeDataCollector", "BraintreePaymentFlow", "BraintreePayPal", "BraintreeThreeDSecure", "BraintreeUnionPay", "BraintreeVenmo", "PayPalDataCollector"]

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

  def xcodebuild(scheme, command, configuration, ios_version, options={}, output_redirect=nil)
    default_options = {
      :build_settings => {}
    }
    ios_version_specifier = ",OS=#{ios_version}" if !ios_version.nil?
    options = default_options.merge(options)
    build_settings = options[:build_settings].map{|k,v| "#{k}='#{v}'"}.join(" ")
    return "set -o pipefail && xcodebuild -workspace 'Braintree.xcworkspace' -sdk 'iphonesimulator' -configuration '#{configuration}' -scheme '#{scheme}' -destination 'name=iPhone 11,platform=iOS Simulator#{ios_version_specifier}' #{build_settings} #{command} #{output_redirect} | ./Pods/xcbeautify/xcbeautify"
  end

end

namespace :spec do
  def run_test_scheme! scheme, configuration, ios_version = nil, output_redirect = nil
    run! xcodebuild(scheme, 'test', configuration, ios_version, {}, output_redirect)
  end

  desc 'Run unit tests'
  task :unit, [:ios_version] do |t, args|
    if args[:ios_version]
      run_test_scheme! 'UnitTests', 'Debug', args[:ios_version]
    else
      run_test_scheme! 'UnitTests', 'Debug'
    end
  end

  desc 'Run UI tests'
  task :ui do
    ENV['NSUnbufferedIO'] = 'YES' #Forces parallel test output to be printed after each test rather than on completion of all tests
    run_test_scheme! 'UITests', 'Release', nil, '2>&1'
    ENV['NSUnbufferedIO'] = 'NO'
  end

  desc 'Run integration tests'
  task :integration do
    run_test_scheme! 'IntegrationTests', 'Release'
  end

  desc 'Run all spec schemes'
  task :all => %w[spec:unit spec:integration spec:ui]
end

desc 'Build Braintree proj demo app'
namespace :demo_app do
  desc 'Verify that the demo app builds successfully'
  task :build_demo do
    run! xcodebuild('Demo', 'build', 'Release', nil)
  end
end

desc 'Carthage tasks'
namespace :carthage do
  def remove_spm_test_app
    run! "mv SampleApps/SPMTest/ temp/"
    run! "git add SampleApps/SPMTest"
    run! "git commit -m 'Remove SPMTest app to avoid Carthage timeout'"
  end

  # Remove SPMTest app to prevent Carthage timeout
  task :remove_spm_test_app do
    run! "mkdir temp"
    remove_spm_test_app
  end

  # Restore SPMTest app to prevent Carthage timeout
  task :restore_spm_test_app do
    run! "mv temp/SPMTest/ SampleApps/"
    run! "rm -rf temp/"
    run! "git add SampleApps/SPMTest"
    run! "git commit -m 'Restore SPMTest app for development'"
  end

  task :build_demo do
    remove_spm_test_app

    # Build Carthage demo app
    File.write("SampleApps/CarthageTest/Cartfile", "git \"file://#{Dir.pwd}\" \"#{current_branch}\"")
    run! "cd SampleApps/CarthageTest && carthage update"
    success = run "xcodebuild -project 'SampleApps/CarthageTest/CarthageTest.xcodeproj' -scheme 'CarthageTest' clean build"

    # Clean up
    run! "rm -rf ~/Library/Developers/Xcode/DerivedData"
    run! "rm SampleApps/CarthageTest/Cartfile.resolved && rm -rf SampleApps/CarthageTest/Carthage"
    run! "git checkout SampleApps/CarthageTest"
    run! "git reset --hard HEAD^"
    fail "xcodebuild command for CarthageTest app returned non-zero exit code" unless success
  end

  desc "Create Braintree.framework.zip for Carthage."
  task :create_frameworks do
    run! "rm -rf SampleApps/SPMTest" # Remove SPMTest app to prevent Carthage timeout
    sh "sh carthage.sh build --no-skip-current"
    sh "sh carthage.sh archive #{bt_modules.join(" ")} --output Braintree.framework.zip"
    run! "git co master SampleApps/SPMTest" # Restore SPMTest app
    say "Create framework binaries for Carthage complete."
  end

  desc "Create Braintree.xcframework.zip for Carthage."
  task :create_xcframeworks do
    run! "rm -rf SampleApps/SPMTest" # Remove SPMTest app to prevent Carthage timeout
-   run! "carthage build --no-skip-current --use-xcframeworks"
    run! "rm -rf Carthage/Build/BraintreeTestShared.xcframework"
    run! "zip -r Braintree.xcframework.zip Carthage"
    run! "git co master SampleApps/SPMTest" # Restore SPMTest app
    say "Create xcframework binaries for Carthage complete."
  end
end

desc 'SPM tasks'
namespace :spm do
  def update_xcodeproj
    project_file = "SampleApps/SPMTest/SPMTest.xcodeproj/project.pbxproj"
    proj = File.read(project_file)
    proj.gsub!(/(repositoryURL = )(.*);/, "\\1\"file://#{Dir.pwd}/\";")
    proj.gsub!(/(branch = )(.*);/, "\\1\"#{current_branch}\";")
    File.open(project_file, "w") { |f| f.puts proj }
  end

  task :build_demo do
    update_xcodeproj

    # Build & archive SPM demo app
    run! "cd SampleApps/SPMTest && swift package resolve"
    run! "xcodebuild -project 'SampleApps/SPMTest/SPMTest.xcodeproj' -scheme 'SPMTest' clean build archive"

    # Clean up
    run! 'rm -rf ~/Library/Developers/Xcode/DerivedData'
    run! 'git checkout SampleApps/SPMTest'
  end


  # Note: This task is for edge case merchants who insist on integrating directly with xcframeworks, though we encourage integrating directly through a package manager instead.
  desc "Create xcframework for each Braintree module."
  task :create_binaries do
    run! "mkdir archive"

    bt_modules.each do |module_name|
      # build .framework for devices
      run! "xcodebuild archive -workspace Braintree.xcworkspace -scheme #{module_name} -sdk iphoneos -archivePath 'archive/iphoneos' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
      # build .framework for simulators
      run! "xcodebuild archive -workspace Braintree.xcworkspace -scheme #{module_name} -sdk iphonesimulator -archivePath 'archive/iphonesimulator' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
      # create xcframework
      run! "xcodebuild -create-xcframework -framework archive/iphoneos.xcarchive/Products/Library/Frameworks/#{module_name}.framework -framework archive/iphonesimulator.xcarchive/Products/Library/Frameworks/#{module_name}.framework -output Braintree-xcframeworks/#{module_name}.xcframework"
    end

    run! "zip -r Braintree-xcframeworks.zip Braintree-xcframeworks/"
    run! "rm -rf archive/ && rm -rf Braintree-xcframeworks/"
    say "Create xcframeworks complete."
  end
end

desc 'Build demo apps per package manager'
task :build_demo_apps => %w[demo_app:build_demo carthage:build_demo spm:build_demo]

namespace :release do
  desc "Print out pre-release checklist"
  task :assumptions do
    say "Release Assumptions"
    say "* [ ] You are on the branch and commit you want to release."
    say "* [ ] You have already merged hotfixes and pulled changes."
    say "* [ ] You have already reviewed the diff between the current release and the last tag, noting breaking changes in the semver and CHANGELOG."
    say "* [ ] Tests (rake spec) are passing, manual verifications complete."

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

    [DEMO_PLIST, FRAMEWORKS_PLIST].each do |plist|
      run! "plutil -replace CFBundleVersion -string #{current_version} -- '#{plist}'"
      run! "plutil -replace CFBundleShortVersionString -string #{current_version} -- '#{plist}'"
    end
    run "git commit -m 'Bump pod version to #{version}' -- #{PODSPEC} Podfile.lock '#{DEMO_PLIST}' '#{FRAMEWORKS_PLIST}' #{BRAINTREE_VERSION_FILE}"
  end

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

  desc  "Push code and tag to GHE"
  task :push_private do
    run! "git push #{GHE_REMOTE_NAME} HEAD #{current_version}"
  end

  desc  "Push code and tag to github.com"
  task :push_public do
    run! "git push #{PUBLIC_REMOTE_NAME} HEAD #{current_version}"
  end

  desc  "Pod push."
  task :push_pod do
    run! "pod trunk push --allow-warnings Braintree.podspec"
  end

  def changelog_entries
    append_lines = false
    lines = ""
    File.read("CHANGELOG.md").each_line do |line|
      if append_lines
        break if line.include?("##") # break when we reach header for previous release
        lines += line
      elsif line.include?("##") # start appending after we find first header
        append_lines = true
      end
    end
    lines
  end

  desc "Create GitHub release & attach .framework binaries for Carthage."
  task :create_github_release do
    run! "gh release create #{current_version} Braintree.framework.zip -t #{current_version} -n '#{changelog_entries}'"
    run! "rm -rf Braintree.framework.zip"
  end

end

def jazzy_command
  %W[jazzy
      --sourcekitten-sourcefile swiftDoc.json,objcDoc.json
      --author Braintree
      --author_url http://braintreepayments.com
      --github_url https://github.com/braintree/braintree_ios
      --github-file-prefix https://github.com/braintree/braintree_ios/tree/#{current_version}
      --theme fullwidth
      --output #{current_version}
  ].join(' ')
end

def sourcekitten_objc_command
  %W[sourcekitten doc --objc Docs/Braintree-Umbrella-Header.h --
      -x objective-c -isysroot $(xcrun --show-sdk-path --sdk iphonesimulator)
      -I $(pwd)/Sources/BraintreeAmericanExpress/Public
      -I $(pwd)/Sources/BraintreeApplePay/Public
      -I $(pwd)/Sources/BraintreeCard/Public
      -I $(pwd)/Sources/BraintreeCore/Public
      -I $(pwd)/Sources/BraintreeDataCollector/Public
      -I $(pwd)/Sources/BraintreePaymentFlow/Public
      -I $(pwd)/Sources/BraintreePayPal/Public
      -I $(pwd)/Sources/BraintreeThreeDSecure/Public
      -I $(pwd)/Sources/BraintreeUnionPay/Public
      -I $(pwd)/Sources/BraintreeVenmo/Public
      > objcDoc.json
  ].join(' ')
end

def sourcekitten_swift_command
  %W[sourcekitten doc --
      -workspace Braintree.xcworkspace
      -scheme PayPalDataCollector
      -destination 'name=iPhone 11,platform=iOS Simulator'
      > swiftDoc.json
  ].join(' ')
end

desc "Generate documentation via jazzy and push to GH"
task :docs_publish => %w[docs:generate docs:publish]

namespace :docs do

  desc "Generate docs with jazzy"
  task :generate do
    begin
      run! "sourcekitten --version"
    rescue => e
      say(HighLine.color("Please run `brew install sourcekitten`", :red, :bold))
      raise
    end

    run! "rm -rf docs_output"
    run(sourcekitten_swift_command)
    run(sourcekitten_objc_command)
    run(jazzy_command)
    run! "rm swiftDoc.json && rm objcDoc.json"
    puts "Generated HTML documentation"
  end

  task :publish do
    run! "git checkout gh-pages"
    run! "ln -sfn #{current_version} current" # update symlink to current version
    run! "git add current #{current_version}"
    run! "git commit -m 'Publish #{current_version} docs to github pages'"
    run! "git push"
    run! "git checkout -"
    puts "Published docs to github pages"
  end
end
