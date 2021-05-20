Pod::Spec.new do |spec|
  spec.name          = "Extendy"
  spec.version       = "1.1.1"
  spec.summary       = "A set of usefull extensions."
  spec.homepage      = "https://github.com/NovichenkoAnton/Extendy"
  
  spec.license       = {:type => 'MIT', :file => 'LICENSE'}
  spec.author        = { "Anton Novichenko" => "novichenko.anton@gmail.com" }
  
  spec.platform      = :ios
  spec.ios.deployment_target = '11.0'
  
  spec.swift_version = '5.0'
  spec.source        = { :git => "https://github.com/NovichenkoAnton/Extendy.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/*.swift"
  spec.requires_arc  = true
end
