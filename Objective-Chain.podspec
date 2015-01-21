Pod::Spec.new do |s|

  s.name         = "Objective-Chain"
  s.version      = "0.2.0"
  s.summary      = "Object-oriented reactive framework, inspired by ReactiveCocoa"
  s.homepage     = "https://github.com/iMartinKiss/Objective-Chain"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Martin Kiss" => "martin.kiss@me.com" }

  s.source       = { :git => "https://github.com/iMartinKiss/Objective-Chain.git", :tag => "#{s.version}" }
  
  s.framework = "Foundation"
  s.framework = "UIKit"

  s.requires_arc = true

  s.source_files  = "Sources/**/*.{h,m}"

end
