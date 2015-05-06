//
//  LazyImage.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros Giampouras. All rights reserved.
//  https://github.com/lamprosg/LazyImage

import Foundation
import UIKit

class LazyImage: NSObject {
    
    
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
        
        //Lazy load image (Asychronous call)
        var width:CGFloat = imageView.bounds.size.width;
        var height:CGFloat = imageView.bounds.size.height;
        
        //In case of default cell images (Dimensions are 0 when not present)
        if height == 0 && width == 0 {
            width = 40;
            height = 40;
        }
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
                                println(actualError)
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
    

}