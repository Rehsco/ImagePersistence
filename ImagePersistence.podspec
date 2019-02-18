Pod::Spec.new do |s|
  s.name             = "ImagePersistence"
  s.version          = "2.2"
  s.license          = 'MIT'
  s.summary          = "Image Assets cache and storage"
  s.author           = { "Martin Jacob Rehder" => "rehscopods_01@rehsco.com" }
  s.homepage         = "http://www.rehsco.com"
  s.source           = { :git => "https://github.com/Rehsco/ImagePersistence.git", :tag => s.version }
  s.swift_version    = '4.2'

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"

  s.requires_arc = true

  s.ios.source_files   = 'ImagePersistence/**/*.swift'
  s.osx.source_files   = 'ImagePersistence-Mac/**/*.swift'

#  s.dependency ''
end
