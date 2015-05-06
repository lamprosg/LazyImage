### LazyImage
Simple and efficient image lazy loading functionality for the iOS written in Swift


### Features
* Makes asynchronous call to fetch the image from a url string
* Provides temporary caching of the downloaded images to the NSTemporaryDirectory, uniquely named based on the url string, to prevent unnecessary requests
* Disables imageView's user interaction until the image is loaded successfully in order to prevent possible gesture recognizer malfunctions
* Offers the possibility to set a local project image as a placeholder until the actual image is available
* If the imageView's size is 0, it sets dimensions to 40x40 prior to the request. This applies to the default UITableViewCells due to the fact when no initial image is present, the imageView is hidden.


### Usage
Find the LazyImage.swift file and copy it to your Swift project.

Show an image on an imageView
```
LazyImage.showForImageView(self.imageView, url:"http://something.com/someimage.png")
```

Show an image with a local image placeholder
```
LazyImage.showForImageView(self.imageView, url:"http://something.com/someimage.png", defaultImage:"someLocalImageName")
```
###License
Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
