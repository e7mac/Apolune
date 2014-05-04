Pod::Spec.new do |s|
  s.name             = "MKChipKit"
  s.version          = "1.0.0"
  s.summary          = "A set of all the chip utility classes and extensions used in our projects."
  s.license          = 'MIT'
  s.homepage           = 'http://www.e7mac.com'
  s.author           = { "e7mac" => "mayank.ot@gmail.com" }
  s.source           = { :git => "https://github.com/e7mac/MKDSPKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/e7mac'

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*'
  # s.resources = 'Assets/**/*'

end
