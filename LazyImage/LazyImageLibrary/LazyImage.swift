//
//  LazyImage.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros Giampouras. All rights reserved.
//  https://github.com/lamprosg/LazyImage

//  Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
//  Version 1.5


import Foundation
import UIKit

class LazyImage: NSObject {

    static var backgroundView:UIView?
    static var oldFrame:CGRect = CGRect()
    static var hasZoom:Bool = false   // Variable to track whether there is currently a zoomed image


    //MARK: - Image lazy loading

    //MARK: Image lazy loading without completion

    class func showForImageView(imageView:UIImageView, url:String?) -> Void {
        self.showForImageView(imageView, url: url, defaultImage: nil) {}
    }

    class func showForImageView(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        self.showForImageView(imageView, url: url, defaultImage: defaultImage) {}
    }


    //MARK: Image lazy loading with completion

    class func showForImageView(imageView:UIImageView, url:String?, completion: () -> Void) -> Void {
        self.showForImageView(imageView, url: url, defaultImage: nil) {

            //Call completion block
            completion()
        }
    }


    class func showForImageView(imageView:UIImageView, url:String?, defaultImage:String?, completion: () -> Void) -> Void {

        if url == nil {
            return //URL is null, don't proceed
        }

        //Clip subviews for image view
        imageView.clipsToBounds = true;

        var isUserInteractionEnabled:Bool = false

        //De-activate interactions while loading.
        //This prevents image gestures not to fire while image is loading.
        if imageView.userInteractionEnabled {

            isUserInteractionEnabled = imageView.userInteractionEnabled
            imageView.userInteractionEnabled = false
        }

        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        let imgName:String = url!.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        //Image path
        let imagePath:String = String(format:"%@/%@", NSTemporaryDirectory(), imgName)

        //Check if image exists
        let imageExists:Bool = NSFileManager.defaultManager().fileExistsAtPath(imagePath)

        if imageExists {

            //check if imageview size is 0
            let width:CGFloat = imageView.bounds.size.width;
            let height:CGFloat = imageView.bounds.size.height;

            //In case of default cell images (Dimensions are 0 when not present)
            if height == 0 && width == 0 {

                var frame:CGRect = imageView.frame
                frame.size.width = 40
                frame.size.height = 40
                imageView.frame = frame
            }

            if let imageData: AnyObject = NSData(contentsOfFile:imagePath) {
                //Image exists
                let dat:NSData = imageData as! NSData

                let image:UIImage = UIImage(data:dat)!

                imageView.image = image;

                if isUserInteractionEnabled {
                    imageView.userInteractionEnabled = true;
                }

                //Completion
                completion()
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
                self.lazyLoadImage(imageView, url: url, isUserInteractionEnabled:isUserInteractionEnabled){

                    //Call completion block
                    completion()
                }
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
            self.lazyLoadImage(imageView, url: url, isUserInteractionEnabled:isUserInteractionEnabled){

                //Completion block reference
                completion()
            }

        }
    }


    class private func lazyLoadImage(imageView:UIImageView, url:String?, isUserInteractionEnabled:Bool, completion: () -> Void) -> Void {

        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        let imgName:String = url!.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        //Image path
        let imagePath:String = String(format:"%@/%@", NSTemporaryDirectory(), imgName)

        let width:CGFloat = imageView.bounds.size.width;
        let height:CGFloat = imageView.bounds.size.height;

        //In case of default cell images (Dimensions are 0 when not present)
        if height == 0 && width == 0 {

            var frame:CGRect = imageView.frame
            frame.size.width = 40
            frame.size.height = 40
            imageView.frame = frame
        }

        //Lazy load image (Asychronous call)
        let urlObject:NSURL = NSURL(string:url!)!
        let urlRequest:NSURLRequest = NSURLRequest(URL: urlObject)

        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_HIGH
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

        dispatch_async(backgroundQueue, {

            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) {(response, data, error) in

                let image:UIImage? = UIImage(data:data!)

                //Go to main thread and update the UI
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    if let img = image {

                        imageView.image = img;

                        //Store image to the temporary folder for later use
                        var error: NSError?

                        do {
                            try UIImagePNGRepresentation(img)!.writeToFile(imagePath, options: [])
                        } catch let error1 as NSError {
                            error = error1
                            if let actualError = error {
                                NSLog("Image not saved. \(actualError)")
                            }
                        } catch {
                            fatalError()
                        }

                        //Turn gestures back on
                        if isUserInteractionEnabled {
                            imageView.userInteractionEnabled = true;
                        }

                        //Completion block
                        completion()
                    }
                })
            }
        })
    }



    /****************************************************/
     //MARK: - Zoom functionality

    class func zoomImageView(imageView:UIImageView) -> Void {

        if imageView.image == nil {
            return  //No image loaded return
        }
        if hasZoom {
            return  //We already have a zoomed image
        } else {
            hasZoom = true  //Well, NOW we do
        }


        backgroundView = UIView()

        //Clip subviews for image view
        imageView.clipsToBounds = true;

        let orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation

        var screenBounds:CGRect = UIScreen.mainScreen().bounds// portrait bounds


        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8 {           //If iOS<8 bounds always gives you the portrait width/height and we have to convert them

            if orientation.isLandscape {
                screenBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width)
            }
        }


        let image:UIImage = imageView.image!
        var window:UIWindow = UIApplication.sharedApplication().keyWindow!

        window = UIApplication.sharedApplication().windows[0]

        backgroundView = UIView(frame: CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height))

        oldFrame = imageView.convertRect(imageView.bounds, toView:window)


        backgroundView!.backgroundColor=UIColor.blackColor()
        backgroundView!.alpha=0;

        let imgV:UIImageView = UIImageView(frame:oldFrame)
        imgV.image=image;
        imgV.tag=1

        backgroundView!.addSubview(imgV)

        window.subviews[0].addSubview(backgroundView!)

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"zoomOutImageView:")
        backgroundView!.addGestureRecognizer(tap)

        UIView.animateWithDuration(0.3, animations: {
            imgV.frame=CGRectMake(0,(screenBounds.size.height-image.size.height*screenBounds.size.width/image.size.width)/2, screenBounds.size.width, image.size.height*screenBounds.size.width/image.size.width)
            self.backgroundView!.alpha=1;
            },
            completion: {(value: Bool) in
                UIApplication.sharedApplication().statusBarHidden = true

                //Track when device is rotated so we can remove the zoomed view
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        })
    }



    class func zoomOutImageView(tap:UITapGestureRecognizer) -> Void {

        UIApplication.sharedApplication().statusBarHidden = false

        let imgV:UIImageView = tap.view?.viewWithTag(1) as! UIImageView

        UIView.animateWithDuration(0.3, animations: {
            imgV.frame = self.oldFrame
            self.backgroundView!.alpha=0
            },
            completion: {(value: Bool) in
                self.backgroundView!.removeFromSuperview()
                self.backgroundView = nil
                hasZoom = false  //No more zoomed view
        })
    }



    class func rotated()
    {
        self.removeZoomedImageView()

        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            //println("landscape")
        }

        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            //println("Portrait")
        }

    }


    class func removeZoomedImageView() -> Void {

        UIApplication.sharedApplication().statusBarHidden = false

        if let bgView = self.backgroundView {

            UIView.animateWithDuration(0.3, animations: {
                bgView.alpha=0
                },
                completion: {(value: Bool) in
                    bgView.removeFromSuperview()
                    self.backgroundView = nil
                    hasZoom = false   //No more zoomed view
            })
        }
    }


    /****************************************************/
     //MARK: - Blur

    class func blurImageView(imageView:UIImageView, style:UIBlurEffectStyle) -> Void {

        if imageView.image == nil {
            return  //No image loaded return
        }

        //Clip subviews for image view
        imageView.clipsToBounds = true;

        let blurEffect = UIBlurEffect(style:style)              //UIBlurEffectStyle.Dark etc..
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
}
