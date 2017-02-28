### iOS - LazyImage
Simple and efficient image lazy loading functionality for the iOS written in Swift

Version 4.0.1


### Features
* Asynchronous image downloader on a background thread. Main thread is never blocked.
* Temporary caching of the downloaded images with automatic OS clean up
* Guarantees that the same image url will not be downloaded again but will be fetched from the cache
* Disables imageView's user interaction until the image is loaded successfully in order to prevent possible developer gesture recognizer issues
* Offers the possibility to set a local project image as a placeholder until the actual image is available
* Offers the possibility to add a spinner at the center of the imageView until the image is fetched
* If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present the imageView is hidden.
* Image can be zoomed to full screen
* Image can be blurred



### Installation
Currently only manual installation is available (1 file)

Find the LazyImage.swift file and copy it to your Swift project. You're done.


### Usage

#### Show an image on an imageView

```
//Create a lazy image object that will hold the instance
lazy var lazyImage:LazyImage = LazyImage()
```

Without completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png")
```

Without completion closure - With spinner
```
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png")
```

With completion closure
```
self.lazyImage.show(imageView:self.imageView, url:"http://something.com/someimage.png") {
    () in
    //Image loaded. Do something..
}
```

With completion closure - With spinner
```
self.lazyImage.showWithSpinner(imageView:self.imageView, url:"http://something.com/someimage.png") {
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
