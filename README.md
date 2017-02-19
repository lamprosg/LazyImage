### LazyImage
Simple and efficient image lazy loading functionality for the iOS written in Swift

Version 3.0.0

### Features
* Makes asynchronous call to fetch the image from a url string
* Provides temporary caching of the downloaded images to the NSTemporaryDirectory, uniquely named based on the url string, to prevent unnecessary requests
* Disables imageView's user interaction until the image is loaded successfully in order to prevent possible gesture recognizer malfunctions
* Offers the possibility to set a local project image as a placeholder until the actual image is available
* If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present, the imageView is hidden.
* Image can be zoomed to full screen
* Image can be blurred
* Bitcode enabled


### Usage
Find the LazyImage.swift file and copy it to your Swift project.

#### Show an image on an imageView

```
//The image object
lazy var lazyImage:LazyImage = LazyImage()
```

Without completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png")
```

With completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png") {
    () in
    //Image loaded. Do something..
}
```

#### Show an image with a local image placeholder

Without completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName")
```

With completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName") {
    () in
    //Image loaded. Do something..
}
```

#### Zoom the image
```
self.lazyImage.zoom(imageView:self.imageView)
```

#### Blur the image (iOS 8 and above)
```
self.lazyImage.blur(imageView:self.imageView, style: UIBlurEffectStyle.Light)
```
###License
Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
