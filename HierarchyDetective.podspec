
Pod::Spec.new do |s|

  s.name         = "HierarchyDetective"
  s.version      = "0.1.0"
  s.summary      = "The Missing View Hierarchy Debugger"

  s.description  = <<-DESC
                   Visualize view hierarchies (UIKit, QuartzCore, Cocos2D or even your own).
                   DESC

  s.homepage     = "http://hierarchydetective.com/"
  
  s.screenshots  = "http://hierarchydetective.com/product/S1.png", "http://hierarchydetective.com/product/S3.png"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }


  s.author       = { "Chinmay Garde" => "chinmaygarde@gmail.com" }

  s.platform     = :ios
  
  s.source       = { :git => "https://github.com/chinmaygarde/hierarchydetective.git", :tag => "0.1.0" }

  s.source_files  = ['Detective/HDServer.m',
                     'Detective/HDDetective.m',
                     'Detective/HDUtils.m',
                     'Detective/NSObject+HDSerialization.m',
                     'Detective/HDMessage.m',
                     'Detective/NSMutableArray+Queue.m',
                     'Detective/HDArgument.m',
                     'Detective/HDScriptArgument.m',
                     'Detective/UIView+HDHelpers.m',
                     'Detective/Base64/NSData+Base64.m',
                     'Detective/Base64/NSString+Base64.m',
                     'Detective/HDUIKitDetective.m',
                     'Detective/HDQuartzDetective.m',
                     'Detective/CALayer+HDHelpers.m',
                     'Detective/NSObject+HDHelpers.m',
                     'Detective/HDGCDAsyncSocket.m',
                     'Detective/HDViewControllerDetective.m',
                     'Detective/UIViewController+HDHelpers.m']
  
  s.public_header_files = []

  s.frameworks = ['QuartzCore', 'CFNetwork', 'Security', 'CoreFoundation', 'UIKit', 'CoreGraphics', 'Foundation']

  s.requires_arc = true

  s.compiler_flags = ['-DBUILDING_LIBRARY']

end
