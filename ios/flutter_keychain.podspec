Pod::Spec.new do |s|
  s.name             = 'flutter_keychain'
  s.version          = '0.0.1'
  s.summary          = 'Flutter secure storage via Keychain and Keystore'
  s.description      = 'Flutter secure storage via Keychain and Keystore.'
  s.homepage         = 'https://github.com/jeroentrappers/flutter_keychain'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jeroen Trappers' => 'jeroen@apple.be' }
  s.source           = { :path => '.' }
  
  # Use Swift sources instead of Obj-C
  s.source_files     = 'Classes/*'
  
  s.dependency 'Flutter'

  s.ios.deployment_target = '15.0' # modern baseline
  s.swift_version = '5.0'
end
