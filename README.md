<p align="center">
<img src="LazyImageLogo.png" title="LazyImage" float=left>
</p>

[![Version](https://img.shields.io/cocoapods/v/LazyImage.svg?style=flat&logo=Swift)](https://cocoapods.org/pods/LazyImage)
[![License](https://img.shields.io/cocoapods/l/LazyImage.svg?style=flat&logo=Swift)](https://cocoapods.org/pods/LazyImage)
[![Platform](https://img.shields.io/cocoapods/p/LazyImage.svg?style=flat&logo=Swift)](https://cocoapods.org/pods/LazyImage)
[![Build Status](https://travis-ci.org/lamprosg/LazyImage.svg?branch=master)](https://travis-ci.org/lamprosg/LazyImage)

Simple and efficient image lazy loading functionality for the iOS written in Swift.
LazyImage offers ease of use and complete control over your images by integrating a very light, need-to-have only, code.


### Features
* Asynchronous image downloader on a background thread. **Main thread is never blocked**.
* **Instance based** for better unit testing your code.
* **Temporary caching** of the downloaded images with automatic OS clean up.
* Offers the possibility to set a local project image as a **placeholder** until the actual image is available
* Offers the possibility to add a **spinner** at the center of the imageView until the image is fetched.
* If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present the imageView is hidden.

### Complete control over your image data
* Guarantees that the same image url will not be downloaded again but will be **fetched from the cache**.
* **Option for force downloading** the same image overriding the cache.
* Option for **clearing images from the cache** which correspond to **specific URLs** so they can be re-downloaded once,
instead of force downloading them continuously.
* Notifies the caller when the operation is complete providing **descriptive error if any**.
* Image can be **scaled** to your specific view dimensions for best performance and **reduced memory allocation**.



### Installation - Cocoapods
```ruby
pod 'LazyImage'
```


### Usage

### LazyImageView

The simplest way to show an image on an image view is by setting the type to LazyImageView and setting the imageURL property.
The downloaded image will be resized to your image view size for best performance.

Example:
```swift
@IBOutlet weak var imageView: LazyImageView!

//Normal image
imageview.image = UIImage(named:"someAsset")

//Network image
imageView.imageURL = "https://domain.com/thepathtotheimage.png"

//Option to enable force download
imageView.forceDownload = true //default: false

//Option to cancel the request
let canceled = imageView.cancelRequest()
```

In case you want to know if the image fails to be retrieved.

Use the LazyImageViewDelegate.

```swift
@IBOutlet weak var imageView: LazyImageView!

imageView.delegate = <your delegate target with conforms to LazyImageViewDelegate>

//Set the image URL
imageView.imageURL = "https://domain.com/thepathtotheimage.png"

//If an error occurs this will be called
//url is the image URL failed to be fetched.
func errorDownloadingImage(url:String) -> Void {

}
```

### LazyImage

#### For more options you can use the LazyImage object on any UIImageview.

#### Show an image on an imageView

Create a lazy image object that will hold the instance.

It is best that you create one instance per object responsible for the image
```swift
lazy var lazyImage:LazyImage = LazyImage()
```

Without completion closure
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png")
```

With spinner
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
```swift
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png") {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Show an image with a local image placeholder

With completion
```swift
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName") {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Show an image with scaled size for better performance

With spinner and new scaled size. Image is resized for your desired size for maximum performance
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Force download an image with scaled size even if it is stored in cache

Sometimes a specific URL can constantly change the corresponding image.

With completion
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showOverride(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```

With completion, spinner and new scaled size
```swift
let newSize = CGSize(width: imageViewWidth height: imageViewHeight)
self.lazyImage.showOverrideWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png", size:newSize) {
(error:LazyImageError?) in
//Image loaded. Do something..
}
```


#### Clearing the cache for specific image URLs

Sometimes you just need to re-download a specific image with the exact same name once.

Clearing the cache
```swift
let imageURLs:[String] = ["https://someimage.png", "https://someotherimage.png"]
self.lazyImage.clearCacheForURLs(urls: urls)
//And you're done
```

#### Forget UIImageviews. Just get the UIImage

```swift
self.lazyImage.fetchImage(url: url) {
 (image:UIImage?, error:LazyImageError?) in
//image has the UIImage
}
```

#### Cancel the image fetching request

```swift
self.lazyImage.cancel()
```

#### Contributing
Contributions are welcomed. Fork the project and make it better, then create a pull request. The project comes with a very basic target app for testing your new features. You can find the library code under Pods/LazyImage. 

#### License
Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
