Pod::Spec.new do |s|
s.name = 'JJCommonCollectionViewLayout_swift'
s.version = '0.0.3'
s.platform = :ios, '8.0'
s.summary = '一个好用的布局，遵守几个代理，即可实现想要的布局。'
s.homepage = 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout_swift'
s.license = 'MIT'
s.author = { 'andyfangjunjie' => 'andyfangjunjie@163.com' }
s.source = {:git => 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout_swift.git', :tag => s.version}
s.source_files = 'JJCommonCollectionViewLayout_swift/**/*.{swift}'
s.requires_arc = true
s.framework  = 'UIKit'
end
