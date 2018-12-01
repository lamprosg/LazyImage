#
# Be sure to run `pod lib lint LazyImage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LazyImage'
  s.version          = '6.7.1'
  s.summary          = 'Simple and efficient image lazy loading for iOS written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Simple and efficient image lazy loading functionality for the iOS written in Swift. LazyImage offers ease of use and complete control over your images.

Features
Asynchronous image downloader on a background thread. Main thread is never blocked.
Instance based for better unit testing your code.
Temporary caching of the downloaded images with automatic OS clean up.
Offers the possibility to set a local project image as a placeholder until the actual image is available
Offers the possibility to add a spinner at the center of the imageView until the image is fetched.
If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present the imageView is hidden.

Complete control over your image data
Guarantees that the same image url will not be downloaded again but will be fetched from the cache.
Option for force downloading the same image overriding the cache.
Option for clearing images from the cache which correspond to specific URLs so they can be re-downloaded once, instead of force downloading them continuously.
Notifies the caller when the operation is complete providing descreptive error if any.
Image can be scaled to your specific view dimensions for best performance and reduced memory allocation.
Image can be zoomed to full screen
Image can be blurred
                       DESC

  s.homepage         = 'https://github.com/lamprosg/LazyImage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache Licence, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Lampros Giampouras' => 'lamprosgiamp@gmail.com' }
  s.source           = { :git => 'https://github.com/lamprosg/LazyImage.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version    = '4.2'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Library/*'
  
  # s.resource_bundles = {
  #   'LazyImage' => ['LazyImage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
