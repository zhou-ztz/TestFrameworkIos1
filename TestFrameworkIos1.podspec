
Pod::Spec.new do |spec|
  spec.name         = "TestFrameworkIos1"
  spec.version      = "1.0.3"
  spec.summary       = "这个是一个测试的demo description of Test-framework"
  spec.description  = <<-DESC
                   这个是一个测试的demo description of TestFrameworkIos1
                   DESC
  spec.homepage     = "https://github.com/zhou-ztz/TestFrameworkIos1"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "tingzhi.zhou" => "tingzhi.zhou@yiartkeji.com" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => 'https://github.com/zhou-ztz/TestFrameworkIos1.git', :tag => '1.0.3'}
  #spec.vendored_frameworks = "TestFrameworkIos1.framework"
  spec.source_files  = "TestFrameworkIos1/**/*.swift"
   #s.source_files = 'Source/**/*.swift'
  spec.requires_arc  = true
  spec.static_framework = true

  spec.dependency "SDWebImage", "5.17.0"
  #spec.dependency "SnapKit"
  spec.dependency "Alamofire", "4.8.1"
  spec.dependency "AppCenter", "4.4.3"
  spec.dependency "RealmSwift", "10.7.7"
  spec.dependency 'lottie-ios', '3.2.3'
  spec.dependency 'SwiftHEXColors'
  spec.dependency 'SwiftyUserDefaults'
  spec.dependency 'EasyTipView', '~> 2.1'
  spec.dependency 'SobotKit', '3.1.3'
  spec.dependency 'ObjectBox', '2.0.0'
  spec.dependency 'BadgeHub'
  spec.dependency 'CropViewController', '~> 2.5.5'
  spec.dependency 'SDWebImageFLPlugin', '0.6.0'
  spec.dependency 'DeepDiff'
  spec.dependency 'Disk'
  spec.dependency "VisualEffectView", '4.1.3'
  spec.dependency 'Hero', '1.6.1'
  spec.dependency 'SDWebImageSwiftUI'
  spec.dependency 'SwiftLinkPreview', '~> 3.3.0'
  spec.dependency 'FSPagerView'
  spec.dependency 'Toast', '~> 4.0'
  spec.dependency 'M80AttributedLabel'
  spec.dependency 'iOSPhotoEditor'
  spec.dependency 'FMDB', '~> 2.7.2'
  spec.dependency 'SSZipArchive', '~> 1.8.1'
  spec.dependency 'SVProgressHUD', '~> 2.1.2'
  spec.dependency 'AliyunVideoSDKPro', '3.16.1'
  spec.dependency 'QuCore-ThirdParty', '4.3.6'
  spec.dependency 'AliPlayerPartSDK_iOS', '~>5.5.5.1'
  spec.dependency 'VODUpload'
  spec.dependency 'AliyunOSSiOS', '2.10.11'
  spec.dependency 'AlivcConan', '1.0.3'
  spec.dependency 'MBProgressHUD', '~> 1.1.0'
  spec.dependency 'JSONModel'
  spec.dependency 'LXReorderableCollectionViewFlowLayout'
  spec.dependency 'TTRangeSlider'
  spec.dependency 'NEMeetingKit', '3.16.1'
  spec.dependency 'NECoreKit', '9.6.3'
  spec.dependency 'YYCategories'
  spec.dependency 'YYText'
  spec.dependency 'YYWebImage'
  spec.dependency 'YYModel'
  spec.dependency 'SwiftyJSON', '4.2.0'   
  spec.dependency 'STRegex', '2.1.0'     
  spec.dependency 'KeychainAccess', '3.1.2'       
  spec.dependency 'SwiftDate'
  spec.dependency 'KMPlaceholderTextView', '1.4.0'   
  spec.dependency 'SnapKit', '5.0.0'                    
  spec.dependency 'MJRefresh', '3.1.16'      
  spec.dependency 'TYAttributedLabel'
  spec.dependency 'Masonry', '1.1.0'   
  spec.dependency 'SCRecorder'
  spec.dependency 'TZImagePickerController'

  spec.dependency 'ObjectMapper', '3.4.2'
  spec.dependency 'ActiveLabel'
  
  spec.dependency 'IQKeyboardManagerSwift', '6.5.0'  
  spec.dependency 'objc-geohash', '0.0.1'      
  spec.dependency 'SwiftEntryKit', '1.2.6' 
  spec.dependency 'Apollo', '0.11.1'
  #spec.dependency 'Floaty'

  spec.dependency 'Lokalise', '~> 0.10.2'
  spec.dependency 'LokaliseLiveEdit'

  spec.dependency 'CryptoSwift', '~> 1.4.0'
  spec.dependency 'Kronos'
  spec.dependency 'libksygpulive/KSYGPUResource'
  spec.dependency 'libksygpulive/libksygpulive' 
  spec.dependency 'PLMediaStreamingKit', '3.0.6'
  spec.dependency 'PusherSwift'
  spec.dependency 'InputBarAccessoryView'

  spec.dependency 'AlipaySDK-iOS', '~> 15.7.9'
  spec.dependency 'TTVideoEditor'

  spec.dependency 'SGPagingView', '~> 1.6.9'
  spec.dependency 'SGPagingView', '~> 1.6.9'
  spec.dependency 'ReactiveObjC', '3.1.1'
  spec.dependency 'MJExtension'
  spec.dependency 'Instructions'
  spec.dependency 'SwiftSoup'
  spec.dependency 'XCGLogger', '~> 7.0.1'
  spec.dependency 'SkyFloatingLabelTextField', '~> 4.0.0'


  #spec.vendored_frameworks = ['Frameworks/SobotKit.framework']
  #spec.xcconfig = {
  #'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  #}

  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
end
