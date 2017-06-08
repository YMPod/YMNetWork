#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YMNetWorking'
  s.version          = '0.0.5'
  s.summary          = ' private comment NetWork .idea from castwy'



  s.description      = <<-DESC

  通用网络库，思路来源  castwy

                       DESC

  s.homepage         = 'https://github.com/YMPod/YMNetWork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "yangm" => "13120690401@163.com" }
  s.source       = { :git => "https://github.com/YMPod/YMNetWork.git", :tag => "#{s.version}" }


  s.ios.deployment_target = '8.0'

  s.source_files = 'Pod/Classes/NetWork/**/*.{h,m}'
  # s.subspec 'APIWorks' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/*.{h,m}'
  # end

  # s.subspec 'APIWorks' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/APIWorks/*.{h,m}'
  # end

  # s.subspec 'CacheComponents' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/CacheComponents/*.{h,m}'
  # end

  # s.subspec 'Helper' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/Helper/*.{h,m}'
  # end

  # s.subspec 'LogComponents' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/LogComponents/*.{h,m}'
  # end

  # s.subspec 'Protocol' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/Protocol/*.{h,m}'
  # end

  # s.subspec 'Service' do |ss|
  #   ss.source_files = 'Pod/Classes/NetWork/Service/*.{h,m}'
  # end

  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
 s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.1.0"

end
