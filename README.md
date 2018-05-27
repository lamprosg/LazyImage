![Alt text](https://camo.githubusercontent.com/11874553c483b3630dff4ac1e54f1d0fb030bb86/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d332e302532422d6f72616e67652e737667 "Swift 3+")
![Alt text](https://camo.githubusercontent.com/1d276aa371242346c77c3a5b8db34beaa2014722/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f694f532d382e302532422d626c75652e737667 "iOS 8+")


### iOS - LazyImage
Simple and efficient image lazy loading functionality for the iOS written in Swift.
LazyImage offers ease of use and complete control over your images.

Version 6.5.0


### Features
* Asynchronous image downloader on a background thread. Main thread is never blocked.
* Instance based for better unit testing your code.
* Temporary caching of the downloaded images with automatic OS clean up.
* Offers the possibility to set a local project image as a placeholder until the actual image is available
* Offers the possibility to add a spinner at the center of the imageView until the image is fetched.
* If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present the imageView is hidden.

### Complete control over your image data
* Guarantees that the same image url will not be downloaded again but will be fetched from the cache.
* Option for force downloading the same image overriding the cache.
* Option for clearing images from the cache which correspond to specific URLs so they can be re-downloaded once,
instead of force downloading them continuously.
* Notifies the caller when the operation is complete providing descreptive error if any.
* Image can be scaled to your specific view dimensions for best performance and reduced memory allocation.
* Image can be zoomed to full screen
* Image can be blurred



### Installation - Cocoapods
```ruby
pod 'LazyImage'
```


### Usage

#### Show an image on an imageView

Create an image object that will hold the instance

It is best that you create one instance per object responsible for the image
```swift
lazy var lazyImage:LazyImage = LazyImage()
```

Without completion closure
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png")
```

Without completion closure - With spinner
```swift
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png")
```

With completion closure
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png") {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```

With completion closure - With spinner
```swift
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png") {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Show an image with a local image placeholder

Without completion closure
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName")
```

With completion closure
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName") {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Show an image with scaled size for better performance

With completion closure and new scaled size
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```

With completion closure - With spinner and new scaled size
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Force download an image with scaled size even if it is stored in cache

With completion closure and new scaled size
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showOverride(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```

With completion closure - With spinner and new scaled size
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showOverrideWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Clearing the cache for specific image URLs

Sometimes you just need to re-download a specific image with the exact same name once.
Maybe you know it has changed and the cache has the old one.

Clearing the cache
```swift
let imageURLs:[String] = ["https://someimage.png", "https://someotherimage.png"]
self.lazyImage.clearCacheForURLs(urls: urls)
//And you're done
```

#### Forget UIImageviews. Just get the UIImage

```swift
self.lazyImage.fetchImage(url: url) {
[weak self] (image:UIImage?, error:LazyImageError?) in
//image has the UIImage
}
```


#### Zoom the image
```swift
self.lazyImage.zoom(imageView:self.imageView)
```

#### Blur the image (iOS 8 and above)
```swift
self.lazyImage.blur(imageView:self.imageView, style: UIBlurEffectStyle.Light)
```
#### License
Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
