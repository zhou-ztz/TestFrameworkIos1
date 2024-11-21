
Pod::Spec.new do |spec|
  spec.name         = "TestFrameworkIos1"
  spec.version      = "1.0.0"
  spec.summary       = "这个是一个测试的demo description of Test-framework"
  spec.description  = <<-DESC
                   这个是一个测试的demo description of TestFrameworkIos1
                   DESC
  spec.homepage     = "https://github.com/zhou-ztz/Test-framework-ios"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "tingzhi.zhou" => "tingzhi.zhou@yiartkeji.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => 'https://github.com/zhou-ztz/Test-framework-ios.git', :tag => '1.0.0'}
  #spec.vendored_frameworks = "TestFrameworkIos1.framework"
  spec.source_files  = "TestFrameworkIos1/**/*.swift"
   #s.source_files = 'Source/**/*.swift'
  spec.requires_arc  = true
  spec.dependency "SDWebImage", "5.17.0"
  spec.dependency "SnapKit"
  spec.dependency "Alamofire", "4.8.1"
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
end
