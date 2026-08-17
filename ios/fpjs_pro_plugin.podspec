Pod::Spec.new do |s|
  s.name             = 'fpjs_pro_plugin'
  s.version          = '4.12.0'
  s.summary          = 'Flutter plugin for FingerprintJS Pro.'
  s.description      = 'Flutter plugin for FingerprintJS Pro.'
  s.homepage         = 'https://github.com/fingerprintjs/fingerprintjs-pro-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FingerprintJS, Inc' => 'support@fingerprint.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'fpjs_pro_plugin/Sources/fpjs_pro_plugin/**/*'
  s.dependency 'Flutter'
  s.dependency 'FingerprintPro', '>= 2.17.0', '< 2.18.0'
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
