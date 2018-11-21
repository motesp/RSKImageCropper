Pod::Spec.new do |s|
  s.name          = 'RSKImageCropper'
  s.version       = '2.1.2'
  s.summary       = 'An image cropper for iOS like in the Contacts app with support for landscape orientation.'
  s.homepage      = 'https://github.com/ruslanskorb/RSKImageCropper'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.authors       = { 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source        = { :git => 'https://github.com/ruslanskorb/RSKImageCropper.git', :tag => s.version.to_s }
  s.platform      = :ios, '9.0'
  s.module_map    = 'RSKImageCropper/RSKImageCropper.modulemap'
  s.source_files  = 'RSKImageCropper/*.{h,m,swift}','Motesplatsen/*.{h,swift}'
  s.resources     = 'RSKImageCropper/RSKImageCropperStrings.bundle','Motesplatsen/ImageCropperOverlay.xib','Motesplatsen/Assets.xcassets'
  s.frameworks    = 'QuartzCore', 'UIKit'
  s.requires_arc  = true
end
