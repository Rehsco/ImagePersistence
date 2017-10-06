Pod::Spec.new do |s|
  s.name             = "ImagePersistence"
  s.version          = "1.2.2"
  s.license          = 'MIT'
  s.summary          = "Image Assets cache and storage"
  s.author           = { "Martin Jacob Rehder" => "rehscopods_01@rehsco.com" }
  s.homepage         = "http://www.rehsco.com"
  s.source           = { :git => "https://github.com/Rehsco/ImagePersistence.git", :tag => s.version }

  s.ios.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/ImagePersistence"' }
  s.ios.preserve_paths = 'ImagePersistence.framework'

  s.osx.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/ImagePersistenceMac"' }
  s.osx.preserve_paths = 'ImagePersistenceMac.framework'

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"

  s.requires_arc = true

  s.ios.source_files   = 'ImagePersistence/*.swift'
  s.osx.source_files   = 'ImagePersistenceMac/*.swift'

  s.ios.public_header_files = 'ImagePersistence/**/*.h'
  s.ios.resources           = 'ImagePersistence/**/*.xcassets'
  s.osx.public_header_files = 'ImagePersistenceMac/**/*.h'
  s.osx.resources           = 'ImagePersistenceMac/**/*.xcassets'

#  s.dependency ''
end
