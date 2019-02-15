//
//  LazyImage+Loader.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 02/01/2019.
//

extension LazyImage {

    //MARK: - Show Image
    
    func load(imageView:UIImageView, url:String?, defaultImage:String?, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        
        self.setupImageBeforeLoading(imageView: imageView, defaultImage: defaultImage)
        
        if url == nil || url!.isEmpty {
            let error: LazyImageError = LazyImageError.CallFailed
            completion(error)
            return //URL is null, don't proceed
        }
        
        //Clip subviews for image view
        imageView.clipsToBounds = true;
        
        //Force download image if required
        if self.forceDownload == true {
            
            //Lazy load image (Asychronous call)
            self.lazyLoad(imageView: imageView, url: url) {
                (error:LazyImageError?) in
                
                //Completion block reference
                completion(error)
            }
            return
        }
        
        //Check if image exists
        let imagePath:String? = self.checkIfImageExists(url: url!)
        
        if let imagePath = imagePath {
            
            self.setUpZeroFramedImageIfNeeded(imageView: imageView)
            
            //Go to the background thread to read the image
            DispatchQueue.global(qos: .userInteractive).async {
                //Try to read the image
                self.readImage(imagePath: imagePath) {
                    [weak self] (image:UIImage?) in
                    
                    if let image = image {
                        //Image read successfully
                        
                        self?.updateImageView(imageView:imageView, fetchedImage:image) {
                            
                            //Completion block
                            //Data available with no errors
                            completion(nil)
                            return
                        }
                    }
                    else {
                        //Image exists but corrupted. Load it again
                        
                        //Lazy load image (Asychronous call)
                        self?.lazyLoad(imageView: imageView, url: url) {
                            (error:LazyImageError?) in
                            
                            //Call completion block
                            completion(error)
                        }
                    }
                }
            }
        }
        else
        {
            //Image does not exist. Load it
            
            //Lazy load image (Asychronous call)
            self.lazyLoad(imageView: imageView, url: url) {
                (error:LazyImageError?) in
                
                //Completion block reference
                completion(error)
            }
            
        }
    }
    
    func lazyLoad(imageView:UIImageView, url:String?, completion: @escaping (_ error:LazyImageError?) -> Void) -> Void {
        
        if url == nil || url!.isEmpty {
            let error: LazyImageError = LazyImageError.CallFailed
            completion(error)
            return //URL is null, don't proceed
        }
        
        //Show spinner
        if self.showSpinner {
            self.showActivityIndicatory(view:imageView)
        }
        
        //Make the call
        self.fetchImage(url: url) {
            
            [weak self] (image:UIImage?, error:LazyImageError?) in
            
            var finalError = error
            if finalError == nil {
                
                if let img = image {
                    
                    let imgName:String? = self?.stripURL(url: url!)
                    
                    //Image path
                    let imagePath:String? = self?.storagePathforImageName(name: imgName!)
                    
                    //Save the image
                    self?.saveImage(image: img, imagePath: imagePath!)
                }
                else {
                    //Completion block
                    //Data available but corrupted
                    finalError = LazyImageError.CorruptedData
                }
            }
            
            //Update the UI
            self?.updateImageView(imageView:imageView, fetchedImage:image) {
                
                //Completion block
                //Data available with no errors
                completion(finalError)
            }
        }
    }
    
    //MARK: Update the image
    
    func updateImageView(imageView:UIImageView, fetchedImage:UIImage?,
                         completion: @escaping () -> Void) -> Void {
        
        //Check if we have a new size
        var image:UIImage? = fetchedImage
        
        if let _ = image,
            let newSize = self.desiredImageSize,
            let fetchedImageSize = fetchedImage?.size,
            !fetchedImageSize.equalTo(newSize) {
            image = self.resize(image: image!, targetSize: newSize)
        }
        
        //Go to main thread and update the UI
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            
            //Hide spinner
            if let _ = self?.showSpinner {
                self?.removeActivityIndicator()
                self?.showSpinner = false
            }
            
            //Set the image
            imageView.image = image;
            
            //Completion block
            completion()
        })
    }
    
    /****************************************************/
    //MARK: - Show activity indicator
    
    private func showActivityIndicatory(view: UIView) {
        
        self.removeActivityIndicator()
        self.spinner = UIActivityIndicatorView()
        self.spinner!.frame = view.bounds
        self.spinner!.hidesWhenStopped = true
        self.spinner!.style = UIActivityIndicatorView.Style.gray
        view.addSubview(self.spinner!)
        self.spinner!.startAnimating()
    }
    
    private func removeActivityIndicator() {
        
        if let spinner = self.spinner {
            
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        //Reset
        self.spinner = nil
    }
    
    /****************************************************/
    //MARK: - Preload setup image
    
    /// Sets up the image before loading with a default image
    private func setupImageBeforeLoading(imageView:UIImageView, defaultImage:String?) -> Void {
        
        if let defaultImg = defaultImage {
            imageView.image = UIImage(named:defaultImg)
        }
    }
    
    //MARK: - Setup 0 framed image
    
    private func setUpZeroFramedImageIfNeeded(imageView:UIImageView) -> Void {
        
        //Check if imageview size is 0
        let width:CGFloat = imageView.bounds.size.width;
        let height:CGFloat = imageView.bounds.size.height;
        
        //In case of default cell images (Dimensions are 0 when not present)
        if height == 0 && width == 0 {
            
            var frame:CGRect = imageView.frame
            frame.size.width = 40
            frame.size.height = 40
            imageView.frame = frame
        }
    }
}
