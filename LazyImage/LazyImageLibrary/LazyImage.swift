//
//  LazyImage.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros Giampouras. All rights reserved.
//  https://github.com/lamprosg/LazyImage

//  Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
//  Version 5.0.0


import Foundation
import UIKit

class LazyImage: NSObject {
    
    var backgroundView:UIView?
    var oldFrame:CGRect = CGRect()
    var imageAlreadyZoomed:Bool = false   // Flag to track whether there is currently a zoomed image
    var showSpinner:Bool = false          // Flag to track wether to show spinner
    var spinner:UIActivityIndicatorView?  // Actual spinner
    var desiredImageSize:CGSize?
    
    //MARK: - Image lazy loading
    
    //MARK: Image lazy loading without completion
    
    func show(imageView:UIImageView, url:String?) -> Void {
        self.show(imageView: imageView, url: url, defaultImage: nil) {}
    }
    
    func showWithSpinner(imageView:UIImageView, url:String?) -> Void {
        self.showSpinner = true
        self.show(imageView: imageView, url: url, defaultImage: nil) {}
    }
    
    func show(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        self.show(imageView: imageView, url: url, defaultImage: defaultImage) {}
    }
    
    func showWithSpinner(imageView:UIImageView, url:String?, defaultImage:String?) -> Void {
        self.showSpinner = true
        self.show(imageView: imageView, url: url, defaultImage: defaultImage) {}
    }
    
    
    //MARK: Image lazy loading with completion
    
    func showWithSpinner(imageView:UIImageView, url:String?, completion: @escaping () -> Void) -> Void {
        self.showSpinner = true
        self.show(imageView: imageView, url: url) {
            
            //Call completion block
            completion()
        }
    }
    
    func show(imageView:UIImageView, url:String?, completion: @escaping () -> Void) -> Void {
        self.show(imageView: imageView, url: url, defaultImage: nil) {
            
            //Call completion block
            completion()
        }
    }
    
    
    //MARK: Image lazy loading with completion and image resizing
    
    func showWithSpinner(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping () -> Void) -> Void {
        self.showSpinner = true
        self.desiredImageSize = size
        self.show(imageView: imageView, url: url) {
            
            //Call completion block
            completion()
        }
    }
    
    func show(imageView:UIImageView, url:String?, size:CGSize, completion: @escaping () -> Void) -> Void {
        self.desiredImageSize = size
        self.show(imageView: imageView, url: url, defaultImage: nil) {
            
            //Call completion block
            completion()
        }
    }
    
    
    func show(imageView:UIImageView, url:String?, defaultImage:String?, completion: @escaping () -> Void) -> Void {
        
        if let defaultImg = defaultImage {
            imageView.image = UIImage(named:defaultImg)
        }
        
        if url == nil || url!.isEmpty {
            return //URL is null, don't proceed
        }
        
        //Clip subviews for image view
        imageView.clipsToBounds = true;
        
        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        let imgName:String = url!.replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        //Image path
        let imagePath:String = String(format:"%@/%@", NSTemporaryDirectory(), imgName)
        
        //Check if image exists
        let imageExists:Bool = FileManager.default.fileExists(atPath: imagePath)
        
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
            
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                //Image exists
                let dat:Data = imageData
                
                var image:UIImage = UIImage(data:dat)!
                
                if let newSize = self.desiredImageSize {
                    image = self.resizeImage(image: image, targetSize: newSize)
                }
                
                imageView.image = image;
                
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
                self.lazyLoad(imageView: imageView, url: url) {
                    
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
                imageView.image = UIImage(named:"") //Blank
            }
            
            //Lazy load image (Asychronous call)
            self.lazyLoad(imageView: imageView, url: url) {
                
                //Completion block reference
                completion()
            }
            
        }
    }
    
    
    fileprivate func lazyLoad(imageView:UIImageView, url:String?, completion: @escaping () -> Void) -> Void {
        
        if url == nil || url!.isEmpty {
            return //URL is null, don't proceed
        }
        
        //Remove all "/" from the url because it will be used as the entire file name in order to be unique
        let imgName:String = url!.replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions.literal, range: nil)
        
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
        
        //Show spinner
        if self.showSpinner {
            self.showActivityIndicatory(view:imageView)
        }
        
        //Lazy load image (Asychronous call)
        let urlObject:URL = URL(string:url!)!
        let urlRequest:URLRequest = URLRequest(url: urlObject)
        
        let backgroundQueue = DispatchQueue(label:"imageBackgroundQue",
                                            qos: .background,
                                            target: nil)
        
        backgroundQueue.async(execute: {
            
            let session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
                
                if response != nil {
                    let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode != 200 {
                        Swift.debugPrint("LazyImage status code : \(httpResponse.statusCode)")
                    }
                }
                
                if data == nil {
                    if error != nil {
                        Swift.debugPrint("Error : \(error!.localizedDescription)")
                    }
                    Swift.debugPrint("LazyImage: No image data available")
                    
                    //Hide spinner
                    DispatchQueue.main.async(execute: { [weak self] () -> Void in
                        if let _ = self?.showSpinner {
                            self?.removeActivityIndicator()
                            self?.showSpinner = false
                        }
                    })
                    return
                }
                
                let image:UIImage? = UIImage(data:data!)
                
                if let img = image {
                    
                    self?.updateImageview(imageView:imageView,
                                          fetchedImage:img,
                                          imagePath:imagePath) {
                                            
                                            //Completion block
                                            completion()
                    }
                }
                else {
                    //Hide spinner
                    DispatchQueue.main.async(execute: { [weak self] () -> Void in
                        if let _ = self?.showSpinner {
                            self?.removeActivityIndicator()
                            self?.showSpinner = false
                        }
                        
                        //Completion block
                        completion()
                    })
                }
            })
            task.resume()
        })
    }
    
    
    
    fileprivate func updateImageview(imageView:UIImageView,
                                     fetchedImage:UIImage,
                                     imagePath:String,
                                     completion: @escaping () -> Void) -> Void {
        
        //Go to main thread and update the UI
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            
            //Check if we have a new size
            var image:UIImage? = fetchedImage
            if let newSize = self?.desiredImageSize {
                image = self?.resizeImage(image: image!, targetSize: newSize)
            }
            
            //Hide spinner
            if let _ = self?.showSpinner {
                self?.removeActivityIndicator()
                self?.showSpinner = false
            }
            
            imageView.image = image!;
            
            //Store image to the temporary folder for later use
            var error: NSError?
            
            do {
                try UIImagePNGRepresentation(fetchedImage)!.write(to: URL(fileURLWithPath: imagePath), options: [])
            } catch let error1 as NSError {
                error = error1
                if let actualError = error {
                    Swift.debugPrint("Image not saved. \(actualError)")
                }
            } catch {
                fatalError()
            }
            
            //Completion block
            completion()
        })
    }
    
    
    /****************************************************/
    //MARK: - Show activity indicator
    
    func showActivityIndicatory(view: UIView) {
        self.spinner = UIActivityIndicatorView()
        self.spinner!.frame = view.bounds
        self.spinner!.hidesWhenStopped = true
        self.spinner!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(self.spinner!)
        self.spinner!.startAnimating()
    }
    
    func removeActivityIndicator() {
        
        if let spinner = self.spinner {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        //Reset
        self.spinner = nil
    }
    
    
    /****************************************************/
    //MARK: - Zoom functionality
    
    func zoom(imageView:UIImageView) -> Void {
        
        if imageView.image == nil {
            return  //No image loaded return
        }
        if imageAlreadyZoomed {
            return  //We already have a zoomed image
        } else {
            imageAlreadyZoomed = true
        }
        
        
        backgroundView = UIView()
        
        //Clip subviews for image view
        imageView.clipsToBounds = true;
        
        let orientation:UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        
        var screenBounds:CGRect = UIScreen.main.bounds// portrait bounds
        
        
        if (UIDevice.current.systemVersion as NSString).floatValue < 8 {           //If iOS<8 bounds always gives you the portrait width/height and we have to convert them
            
            if orientation.isLandscape {
                screenBounds = CGRect(x: 0, y: 0, width: screenBounds.size.height, height: screenBounds.size.width)
            }
        }
        
        
        let image:UIImage = imageView.image!
        var window:UIWindow = UIApplication.shared.keyWindow!
        
        window = UIApplication.shared.windows[0]
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.size.width, height: screenBounds.size.height))
        
        oldFrame = imageView.convert(imageView.bounds, to:window)
        
        
        backgroundView!.backgroundColor=UIColor.black
        backgroundView!.alpha=0;
        
        let imgV:UIImageView = UIImageView(frame:oldFrame)
        imgV.image=image;
        imgV.tag=1
        
        backgroundView!.addSubview(imgV)
        
        window.subviews[0].addSubview(backgroundView!)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(LazyImage.zoomOutImageView(_:)))
        backgroundView!.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.3, animations: {
            imgV.frame=CGRect(x: 0,y: (screenBounds.size.height-image.size.height*screenBounds.size.width/image.size.width)/2, width: screenBounds.size.width, height: image.size.height*screenBounds.size.width/image.size.width)
            self.backgroundView!.alpha=1;
        },
                       completion: {(value: Bool) in
                        UIApplication.shared.isStatusBarHidden = true
                        
                        //Track when device is rotated so we can remove the zoomed view
                        NotificationCenter.default.addObserver(self, selector:#selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        })
    }
    
    
    
    func zoomOutImageView(_ tap:UITapGestureRecognizer) -> Void {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let imgV:UIImageView = tap.view?.viewWithTag(1) as! UIImageView
        
        UIView.animate(withDuration: 0.3, animations: {
            imgV.frame = self.oldFrame
            self.backgroundView!.alpha=0
        },
                       completion: {(value: Bool) in
                        self.backgroundView!.removeFromSuperview()
                        self.backgroundView = nil
                        self.imageAlreadyZoomed = false  //No more zoomed view
        })
    }
    
    
    
    func rotated()
    {
        self.removeZoomedImageView()
        
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            //println("landscape")
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            //println("Portrait")
        }
        
    }
    
    
    func removeZoomedImageView() -> Void {
        
        UIApplication.shared.isStatusBarHidden = false
        
        if let bgView = self.backgroundView {
            
            UIView.animate(withDuration: 0.3, animations: {
                bgView.alpha=0
            },
                           completion: {(value: Bool) in
                            bgView.removeFromSuperview()
                            self.backgroundView = nil
                            self.imageAlreadyZoomed = false
            })
        }
    }
    
    
    /****************************************************/
    //MARK: - Resize image
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let horizontalRatio:CGFloat = targetSize.width / image.size.width
        let verticalRatio:CGFloat = targetSize.height / image.size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    /****************************************************/
    //MARK: - Blur
    
    func blur(imageView:UIImageView, style:UIBlurEffectStyle) -> UIVisualEffectView? {
        
        if imageView.image == nil {
            return nil  //No image loaded return
        }
        
        //Clip subviews for image view
        imageView.clipsToBounds = true;
        
        let blurEffect = UIBlurEffect(style:style)              //UIBlurEffectStyle.Dark etc..
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(blurView)
        return blurView
    }
    
}
