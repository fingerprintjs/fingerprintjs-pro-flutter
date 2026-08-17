# Package.swift is the single source of truth for the FingerprintPro version range, mirroring
# android/fingerprint.gradle on the Android side. `.upToNextMinor(from: "X.Y.Z")` there means
# >= X.Y.Z and < X.(Y+1).0, which is what CocoaPods gets told below.
fingerprint_pro_lower = File.read(File.join(__dir__, 'fpjs_pro_plugin', 'Package.swift'))[/\.upToNextMinor\(from: "([\d.]+)"\)/, 1]
raise 'Could not read the FingerprintPro version range from Package.swift' if fingerprint_pro_lower.nil?
major, minor, = fingerprint_pro_lower.split('.').map(&:to_i)
fingerprint_pro_upper = "#{major}.#{minor + 1}.0"

Pod::Spec.new do |s|
  s.name             = 'fpjs_pro_plugin'
  s.version          = '4.12.0'
  s.summary          = 'Flutter plugin for FingerprintJS Pro.'
  s.description      = 'Flutter plugin for FingerprintJS Pro.'
  s.homepage         = 'https://github.com/fingerprintjs/fingerprintjs-pro-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FingerprintJS, Inc' => 'support@fingerprint.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'fpjs_pro_plugin/Sources/fpjs_pro_plugin/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'FingerprintPro', ">= #{fingerprint_pro_lower}", "< #{fingerprint_pro_upper}"
  s.platform         = :ios, '13.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/*'
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
