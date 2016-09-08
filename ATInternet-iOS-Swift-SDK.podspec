Pod::Spec.new do |s|
	s.name						      = "ATInternet-iOS-Swift-SDK"
	s.version					      = '2.2.5'
	s.summary					      = "AT Internet mobile analytics solution for iOS"
	s.homepage				      = "https://github.com/at-internet/atinternet-ios-swift-sdk"
	s.documentation_url	    = 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license					      = "MIT"
	s.author					      = "AT Internet"
	s.platform					    = :ios
  s.ios.deployment_target	= '8.0'
	s.source					      = { :git => "https://github.com/at-internet/atinternet-ios-swift-sdk.git", :tag => s.version}

	s.subspec 'Res' do |res|
		res.resources = "Tracker/Tracker/DefaultConfiguration.plist","Tracker/Tracker/core.manifest.json","Tracker/Tracker/*.{xcdatamodeld,png,json}", "Tracker/Tracker/Images.xcassets"
	end

	s.subspec 'iOS' do |ios|
		ios.source_files	= "Tracker/Tracker/*.{h,m,swift}"
		ios.frameworks		= "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration"
		ios.dependency s.name+'/Res'
	end

	s.subspec 'AppExtension' do |appExt|
		appExt.pod_target_xcconfig		= { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
		appExt.source_files           = "Tracker/Tracker/*.{h,m,swift}"
		appExt.exclude_files          = "Tracker/Tracker/BackgroundTask.{swift}"
		appExt.frameworks             = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "CoreTelephony", "SystemConfiguration"
		appExt.dependency s.name+'/Res'
	end
  
	s.module_name = 'Tracker'
	s.requires_arc = true
end
