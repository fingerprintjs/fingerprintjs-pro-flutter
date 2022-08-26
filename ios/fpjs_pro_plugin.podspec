#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fpjs_pro_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fpjs_pro_plugin'
  s.version          = '1.0.4'
  s.summary          = 'Flutter plugin for FingerprintJS Pro.'
  s.description      = <<-DESC
Flutter plugin for FingerprintJS Pro.
                       DESC
  s.homepage         = 'https://github.com/fingerprintjs/fingerprintjs-pro-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FingerprintJS, Inc (https://fingerprint.com)' => 'boris.lobanov@fingerprintjs.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FingerprintPro', '~> 2.1.0'

  s.platform = :ios, '13.0'

  s.xcconfig = {
    "LIBRARY_SEARCH_PATHS" => '"${PROJECT_DIR}/.."/*',
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
