//
//  LazyImage.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros Giampouras. All rights reserved.
//  https://github.com/lamprosg/LazyImage

//  Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0


import Foundation
import UIKit

open class LazyImage: NSObject {
    
    var backgroundView:UIView?
    var oldFrame:CGRect = CGRect()
    var imageAlreadyZoomed:Bool = false     // Flag to track whether there is currently a zoomed image
    var showSpinner:Bool = false            // Flag to track wether to show spinner
    var forceDownload:Bool = false          // Flag to force download an image even if it is cached on the disk
    var spinner:UIActivityIndicatorView?    // Actual spinner
    var desiredImageSize:CGSize?            // Image size requested for resizing for a specific fetch operation.
    var cacheSize:CGSize?            // Default image size. Images will be stored in cache according to this size

    /// The URL session request
    var session:URLSession?
    
    //MARK: - Image lazy loading
    
    //MARK: - Image lazy loading without completion
    
    /// Downloads and shows an image URL to the specified image view
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    public func show(imageView:UIImageView, url:String?) -> Void {
        self.showSpinner = false
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {_ in}
    }
    
    /// Downloads and shows an image URL to the specified image view presenting a spinner until the data are fully downloaded
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    public func showWithSpinner(imageView:UIImageView, url:String?) -> Void {
        self.showSpinner = true
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {_ in}
    }
    
    /// Downloads and shows an image URL to the specified image view presenting a default image until the data are fully downloaded
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - defaultImage: The default image to be shown until the image data are fully downloaded
    public func show(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        self.showSpinner = false
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: defaultImage) {_ in}
    }
    
    /// Downloads and shows an image URL to the specified image view presenting both a default image and a spinner until the data are fully downloaded
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - defaultImage: The default image to be shown until the image data are fully downloaded
    public func showWithSpinner(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        self.showSpinner = true
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: defaultImage) {_ in}
    }
    
    //MARK: - Image lazy loading with completion
    
    /// Downloads and shows an image URL to the specified image view presenting a spinner until the data are fully downloaded
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showWithSpinner(imageView:UIImageView, url:String?, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = true
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }
    
    /// Downloads and shows an image URL to the specified image view
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func show(imageView:UIImageView, url:String?, completion: @escaping ( _ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = true
        self.forceDownload = false
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }
    
    //MARK: - Image lazy loading with completion and image resizing
    
    /// Downloads and shows an image URL to the specified image view presenting a spinner until the data are fully downloaded.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showWithSpinner(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = true
        self.forceDownload = false
        self.desiredImageSize = size
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }
    
    /// Downloads and shows an image URL to the specified image view.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func show(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = false
        self.forceDownload = false
        self.desiredImageSize = size
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }

    //MARK: - Image lazy loading with force download

    /// Force downloads, even if cached, and shows an image URL to the specified image view presenting a spinner.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showOverrideWithSpinner(imageView:UIImageView, url:String?) -> Void {
        self.showSpinner = true
        self.forceDownload = true
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {_ in}
    }

    /// Force downloads, even if cached, and shows an image URL to the specified image view.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showOverride(imageView:UIImageView, url:String?) -> Void {
        self.showSpinner = false
        self.forceDownload = true
        self.desiredImageSize = nil
        self.load(imageView: imageView, url: url, defaultImage: nil) {_ in}
    }
    
    //MARK: - Image lazy loading with force download, with completion and image resizing
    
    /// Force downloads, even if cached, and shows an image URL to the specified image view presenting a spinner.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showOverrideWithSpinner(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = true
        self.forceDownload = true
        self.desiredImageSize = size
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }
    
    /// Force downloads, even if cached, and shows an image URL to the specified image view.
    /// The image is rescaled according to the size provided for better rendering
    ///
    /// - Parameters:
    ///   - imageView: The image view reference to show the image
    ///   - url: The URL of the image to be downloaded
    ///   - size: The new scaling size of the image. Size will be used to calculate the ratio of the new sized image.
    ///   - completion: The completion closure when the data are fully downloaded and presented on the image view
    public func showOverride(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        self.showSpinner = false
        self.forceDownload = true
        self.desiredImageSize = size
        self.load(imageView: imageView, url: url, defaultImage: nil) {
            (error:LazyImageError?) in
            
            //Call completion block
            completion(error)
        }
    }

    //MARK: - Prefetch image

    /// Prefetched an image and saves it in cache ready for display.
    ///
    /// - Parameter url: The url to be fetched
    public func prefetchImage(url: String?) -> Void {

        self.fetchImage(url: url) { [weak self] (image:UIImage?, error:LazyImageError?) in
            guard let fetchedImage = image else {
                return
            }

            if error == nil {
                let imgName:String? = self?.stripURL(url: url!)
                let imagePath:String? = self?.storagePathforImageName(name: imgName!)

                //Save the image
                self?.saveImage(image: fetchedImage, imagePath: imagePath!)
            }
        }
    }

    //MARK: - Default cache image size

    /// The new default scaling size of the image. This size will be used to calculate the ratio of the new image. The new sized image will be stored in cache instead of the original one. Use this method to store specific size ration images in cache for faster display.
    ///
    /// - Parameter size: The new default scaling size of the image
    public func setCacheSize(_ size:CGSize?) -> Void {
        self.cacheSize = size
    }
}
