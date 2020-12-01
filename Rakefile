require 'tempfile'
require 'fileutils'
require 'shellwords'
require 'bundler'
Bundler.require
HighLine.color_scheme = HighLine::SampleColorScheme.new

task :default => %w[sanity_checks spec]

desc "Run all test tasks"
task :spec => %w[spec:all]

desc "Run internal release process, pushing to internal GitHub Enterprise only"
task :release => %w[release:assumptions sanity_checks release:check_working_directory release:bump_version release:lint_podspec carthage:create_binaries spm:create_binaries release:tag release:push_private]

desc "Publish code and pod to public github.com"
task :publish => %w[publish:push publish:push_pod publish:create_github_release docs_internal docs_external]

SEMVER = /\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?/
PODSPEC = "Braintree.podspec"
BRAINTREE_VERSION_FILE = "Sources/BraintreeCore/Braintree-Version.h"
DEMO_PLIST = "Demo/Application/Supporting Files/Braintree-Demo-Info.plist"
FRAMEWORKS_PLIST = "Sources/BraintreeCore/Info.plist"
PUBLIC_REMOTE_NAME = "public"

bt_modules = ["BraintreeAmericanExpress", "BraintreeApplePay", "BraintreeCard", "BraintreeCore", "BraintreeDataCollector","BraintreePaymentFlow", "BraintreePayPal", "BraintreeThreeDSecure", "BraintreeUnionPay", "BraintreeVenmo", "PayPalDataCollector"]

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

desc 'Build Braintree proj demo app'
namespace :demo do
  desc 'Verify that the demo app builds successfully'
  task :build do
    run! xcodebuild('Demo', 'build', 'Release', nil)
  end
end

desc 'Carthage tasks'
namespace :carthage do
  def generate_cartfile
    File.write("SampleApps/CarthageTest/Cartfile", "git \"file://#{Dir.pwd}\" \"#{current_branch}\"")
  end

  task :build_demo do
    # Remove SPMTest app to prevent Carthage timeout
    run! "rm -rf SampleApps/SPMTest"
    run! "git add SampleApps"
    run! "git commit -m 'Remove SPMTest app to avoid Carthage timeout'"

    # Build Carthage demo app
    generate_cartfile
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
  task :create_binaries do
    run! "rm -rf SampleApps/SPMTest" # Remove SPMTest app to prevent Carthage timeout
    run! "carthage.sh build --no-skip-current"
    run! "carthage.sh archive #{bt_modules.join(" ")} --output Braintree.framework.zip"
    run! "git co master SampleApps/SPMTest" # Restore SPMTest app
    say "Create binaries for Carthage complete."
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

  task :clean do
    run! 'rm -rf ~/Library/Developers/Xcode/DerivedData'
    run! 'git checkout SampleApps/SPMTest'
  end

  task :build_demo do
    update_xcodeproj
    run! "cd SampleApps/SPMTest && swift package resolve"
    run! "xcodebuild -project 'SampleApps/SPMTest/SPMTest.xcodeproj' -scheme 'SPMTest' clean build"
  end

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

desc 'Run all sanity checks'
task :sanity_checks => %w[sanity_checks:pending_specs sanity_checks:build_demo sanity_checks:carthage_test sanity_checks:spm_test]

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

  desc 'Verify that Braintree demo app builds successfully'
  task :build_demo => 'demo:build'

  desc 'Verify that Carthage demo builds successfully'
  task :carthage_test => %w[carthage:build_demo]

  desc 'Verify that SPM demo builds successfully'
  task :spm_test => %w[spm:build_demo spm:clean]
end

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

  desc  "Push code and tag to github.com"
  task :push do
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

  desc "Create GitHub release & attach .framework and .xcframework binaries."
  task :create_github_release do
    run! "gh release create #{current_version} Braintree.framework.zip Braintree-xcframeworks.zip -t #{current_version} -n '#{changelog_entries}'"
    run! "rm -rf Braintree.framework.zip && rm -rf Braintree-xcframeworks.zip"
  end

end

def jazzy_command
  %W[jazzy
      --objc
      --author Braintree
      --author_url http://braintreepayments.com
      --github_url https://github.com/braintree/braintree_ios
      --github-file-prefix https://github.com/braintree/braintree_ios/tree/#{current_version}
      --theme fullwidth
      --output docs_output
      --xcodebuild-arguments --objc,Docs/Braintree-Umbrella-Header.h,--,-x,objective-c,-isysroot,$(xcrun --sdk iphonesimulator --show-sdk-path),-I,$(pwd)
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
