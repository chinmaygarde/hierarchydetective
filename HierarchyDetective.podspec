
Pod::Spec.new do |s|

  s.name         = "HierarchyDetective"
  s.version      = "0.1.1"
  s.summary      = "The Missing View Hierarchy Debugger"

  s.description  = <<-DESC
                   Visualize view hierarchies (UIKit, QuartzCore, Cocos2D or even your own).
                   DESC

  s.homepage     = "http://hierarchydetective.com/"
  
  s.screenshots  = "http://hierarchydetective.com/product/S1.png", "http://hierarchydetective.com/product/S3.png"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }


  s.author       = { "Chinmay Garde" => "chinmaygarde@gmail.com" }

  s.platform     = :ios, "5.0"
  
  s.source       = { :git => "https://github.com/chinmaygarde/hierarchydetective.git", :tag => "0.1.1" }

  s.source_files  = [
    'Detective/*.{h,m}',
    'Detective/Base64/*.{h,m}',
    'Detective/Aspects/ViewControllerContainment/*.{h,m}',
  ]
  
  s.public_header_files = []

  s.exclude_files = [
    'Detective/HDScriptRunner.m',
    'Detective/Aspects/Cocos2D/*.{h,m}',
  ]

  s.frameworks = ['QuartzCore', 'CFNetwork', 'Security', 'CoreFoundation', 'UIKit', 'CoreGraphics', 'Foundation']

  s.requires_arc = true

  s.compiler_flags = ['-DBUILDING_LIBRARY']

  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }

end
