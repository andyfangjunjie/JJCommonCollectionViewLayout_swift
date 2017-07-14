Pod::Spec.new do |s|
//名称
s.name = 'JJCommonCollectionViewLayout_swift'
//版本号
s.version = '0.0.1'
//支持平台
s.platform = :ios, '7.0'
//简介
s.summary = '一个好用的布局，遵守几个代理，即可实现想要的布局。'
//主页
s.homepage = 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout_swift'
//许可证
s.license = 'MIT'
//作者
s.author = { 'andyfangjunjie' => 'andyfangjunjie@163.com' }
//项目地址
s.source = {:git => 'https://github.com/andyfangjunjie/JJCommonCollectionViewLayout_swift.git', :tag => s.version}
//资源文件
s.source_files = 'JJCommonCollectionViewLayout_swift/**/*.{h,m}'
//是否支持ARC
s.requires_arc = true
//项目中用到库，多个用英文逗号隔开
s.framework  = 'UIKit'
end
