# Keep CocoaPods and Swift Package Manager on the same v4 major.
fingerprint_lower = File.read(File.join(__dir__, 'fpjs_pro_plugin', 'Package.swift'))[/\.upToNextMajor\(from: "([\d.]+)"\)/, 1]
raise 'Could not read the Fingerprint version range from Package.swift' if fingerprint_lower.nil?
fingerprint_major, = fingerprint_lower.split('.').map(&:to_i)
fingerprint_upper = "#{fingerprint_major + 1}.0.0"

Pod::Spec.new do |s|
  s.name             = 'fpjs_pro_plugin'
  s.version          = '5.0.0'
  s.summary          = 'Flutter plugin for FingerprintJS Pro.'
  s.description      = 'Flutter plugin for FingerprintJS Pro.'
  s.homepage         = 'https://github.com/fingerprintjs/fingerprintjs-pro-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FingerprintJS, Inc' => 'support@fingerprint.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'fpjs_pro_plugin/Sources/fpjs_pro_plugin/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'Fingerprint-iOS', ">= #{fingerprint_lower}", "< #{fingerprint_upper}"
  s.platform         = :ios, '15.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/*'
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '6.0'
end
