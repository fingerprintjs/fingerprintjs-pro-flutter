# Keep CocoaPods and Swift Package Manager on the same v4 major.
fingerprint_lower = File.read(File.join(__dir__, 'fingerprint_flutter', 'Package.swift'))[/\.upToNextMajor\(from: "([\d.]+)"\)/, 1]
raise 'Could not read the Fingerprint version range from Package.swift' if fingerprint_lower.nil?
fingerprint_major, = fingerprint_lower.split('.').map(&:to_i)
fingerprint_upper = "#{fingerprint_major + 1}.0.0"

Pod::Spec.new do |s|
  s.name             = 'fingerprint_flutter'
  s.version          = '4.13.1'
  s.summary          = 'Flutter plugin for Fingerprint.'
  s.description      = 'Flutter plugin for Fingerprint.'
  s.homepage         = 'https://github.com/fingerprintjs/fingerprintjs-pro-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FingerprintJS, Inc' => 'support@fingerprint.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'fingerprint_flutter/Sources/fingerprint_flutter/**/*.swift'
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
