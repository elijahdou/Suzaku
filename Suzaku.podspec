Pod::Spec.new do |s|
  s.name             = 'Suzaku'
  s.version          = '0.0.2'
  s.summary          = 'Suzaku is a swift version of the hashed wheel timer.'
  s.description      = <<-DESC
Suzaku is a swift version of a lightweight hashed wheel timer that can be used for efficient management of intensive timing tasks
                       DESC
  s.homepage         = 'https://github.com/elijahdou/Suzaku'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'elijahdou' => 'elijahdou@gmail.com' }
  s.source           = { :git => 'https://github.com/elijahdou/Suzaku.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'Suzaku/Classes/**/*'
end
