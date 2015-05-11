//
//  LazyImage.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros Giampouras. All rights reserved.
//  https://github.com/lamprosg/LazyImage

//  Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
//  Version 1.2


import Foundation
import UIKit

class LazyImage: NSObject {
    
    static var backgroundView:UIView = UIView()
    static var oldFrame:CGRect = CGRect()
    
    // MARK: Image lazy loading
    
    class func showForImageView(imageView:UIImageView, url:String?) -> Void {
        self.showForImageView(imageView, url: url, defaultImage: nil)
    }
    
    
    class func showForImageView(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        
        if url == nil {
            return //URL is null, don't proceed
        }
        
        var isUserInteractionEnabled:Bool = false
        
        //De-activate interactions while loading.
        //This prevents image gestures not to fire while image is loading.
        if imageView.userInteractionEnabled {
            
            isUserInteractionEnabled = imageView.userInteractionEnabled
            imageView.userInteractionEnabled = false
        }
        
        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        var imgName:String = url!.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //Image path
        var imagePath:String = String(format:"%@/%@", NSTemporaryDirectory(), imgName)
        
        //Check if image exists
        var imageExists:Bool = NSFileManager.defaultManager().fileExistsAtPath(imagePath)
        
        if imageExists {
            
            //check if imageview size is 0
            var width:CGFloat = imageView.bounds.size.width;
            var height:CGFloat = imageView.bounds.size.height;
            
            //In case of default cell images (Dimensions are 0 when not present)
            if height == 0 && width == 0 {
                
                var frame:CGRect = imageView.frame
                frame.size.width = 40
                frame.size.height = 40
                imageView.frame = frame
            }

            if let imageData: AnyObject = NSData(contentsOfFile:imagePath) {
                //Image exists
                var dat:NSData = imageData as! NSData
                
                var image:UIImage = UIImage(data:dat)!
                
                imageView.image = image;
                
                if isUserInteractionEnabled {
                    imageView.userInteractionEnabled = true;
                }
            }
            else {
                //Image exists but corrupted. Load it again
                if let defaultImg = defaultImage {
                    imageView.image = UIImage(named:defaultImg)
                }
                else {
                    imageView.image = UIImage(named:"")
                }
                
                //Lazy load image (Asychronous call)
                self.lazyLoadImage(imageView, url: url, isUserInteractionEnabled:isUserInteractionEnabled)
            }
        }
        else
        {
            //Image does not exist. Load it
            if let defaultImg = defaultImage {
                imageView.image = UIImage(named:defaultImg)
            }
            else {
                imageView.image = UIImage(named:"")
            }
            
            //Lazy load image (Asychronous call)
            self.lazyLoadImage(imageView, url: url, isUserInteractionEnabled:isUserInteractionEnabled)
            
        }
    }
    
    
    class private func lazyLoadImage(imageView:UIImageView, url:String?, isUserInteractionEnabled:Bool) -> Void {
        
        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        var imgName:String = url!.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //Image path
        var imagePath:String = String(format:"%@/%@", NSTemporaryDirectory(), imgName)
        
        var width:CGFloat = imageView.bounds.size.width;
        var height:CGFloat = imageView.bounds.size.height;
        
        //In case of default cell images (Dimensions are 0 when not present)
        if height == 0 && width == 0 {
            
            var frame:CGRect = imageView.frame
            frame.size.width = 40
            frame.size.height = 40
            imageView.frame = frame
        }
        
        //Lazy load image (Asychronous call)
        var urlObject:NSURL = NSURL(string:url!)!
        var urlRequest:NSURLRequest = NSURLRequest(URL: urlObject)
        
        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_HIGH
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                
                var image:UIImage? = UIImage(data:data)
                
                //Go to main thread and update the UI
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if let img = image {
                        
                        imageView.image = img;
                        
                        //Store image to the temporary folder for later use
                        var error: NSError?
                        
                        if !UIImagePNGRepresentation(img).writeToFile(imagePath, options: nil, error: &error) {
                            if let actualError = error {
                                NSLog("Image not saved. \(actualError)")
                            }
                        }
                        
                        //Turn gestures back on
                        if isUserInteractionEnabled {
                            imageView.userInteractionEnabled = true;
                        }
                    }
                })
            }
        })
    }
    
    
    
    /****************************************************/
    // MARK: Zoom functionality
    
    class func zoomImageView(imageView:UIImageView) -> Void {
        
        if imageView.image == nil {
            return  //No image loaded return
        }
        
        
        var orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        var screenBounds:CGRect = UIScreen.mainScreen().bounds// portrait bounds
        
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8 {           //If iOS<8 bounds always gives you the portrait width/height and we have to convert them
        
            if orientation.isLandscape {
                screenBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width)
            }
        }

        
        var image:UIImage = imageView.image!
        var window:UIWindow = UIApplication.sharedApplication().keyWindow!

        window = UIApplication.sharedApplication().windows[0] as! UIWindow
        
        backgroundView = UIView(frame: CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height))
        
        oldFrame = imageView.convertRect(imageView.bounds, toView:window)
        
        
        backgroundView.backgroundColor=UIColor.blackColor()
        backgroundView.alpha=0;
        
        var imgV:UIImageView = UIImageView(frame:oldFrame)
        imgV.image=image;
        imgV.tag=1;
        
        backgroundView.addSubview(imgV)
        
        window.subviews[0].addSubview(backgroundView)
        
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"hideImage:")
        backgroundView.addGestureRecognizer(tap)
        
        UIView.animateWithDuration(0.3, animations: {
            imgV.frame=CGRectMake(0,(screenBounds.size.height-image.size.height*screenBounds.size.width/image.size.width)/2, screenBounds.size.width, image.size.height*screenBounds.size.width/image.size.width)
            self.backgroundView.alpha=1;
            },
            completion: {(value: Bool) in
                UIApplication.sharedApplication().statusBarHidden = true
        })
    }
    
    
    
    class func hideImage(tap:UITapGestureRecognizer) -> Void {
    
        UIApplication.sharedApplication().statusBarHidden = false
        
        var bgView:UIView = tap.view!
        var imgV:UIImageView = tap.view?.viewWithTag(1) as! UIImageView
        
        UIView.animateWithDuration(0.3, animations: {
            imgV.frame = self.oldFrame
            self.backgroundView.alpha=0
            },
            completion: {(value: Bool) in
                self.backgroundView.removeFromSuperview()
        })
    }
    
}