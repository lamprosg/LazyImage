//
//  LazyImage+Storage.swift
//  Pods
//
//  Created by Lampros Giampouras on 02/01/2019.
//

extension LazyImage {

    //MARK: - URL string stripping
    
    //TODO: Change this to hash the url
    func stripURL(url:String) -> String {
        return url.replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    /*
     private func SHA256(url:String) -> String {
     
     let data = url(using: String.Encoding.utf8)
     let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
     CC_SHA256(((data! as NSData)).bytes, CC_LONG(data!.count), res?.mutableBytes.assumingMemoryBound(to: UInt8.self))
     let hashedString = "\(res!)".replacingOccurrences(of: "", with: "").replacingOccurrences(of: " ", with: "")
     let badchar: CharacterSet = CharacterSet(charactersIn: "\"<\",\">\"")
     let cleanedstring: String = (hashedString.components(separatedBy: badchar) as NSArray).componentsJoined(by: "")
     return cleanedstring
     
     }
     */
    
    //MARK: - Image storage
    
    /// The storage path for a given image unique name
    ///
    /// - Parameter name: The unique name of the image
    /// - Returns: Returns the storage path
    func storagePathforImageName(name:String) -> String {

        var path = String(format:"%@/%@", NSTemporaryDirectory(), name)

        if let cacheSize = self.cacheSize {
            path = path + "\(cacheSize.width)" + "x" + "\(cacheSize.height)"
        }
        return path
    }
    
    /// Saves an image to a given storage path
    ///
    /// - Parameters:
    ///   - image: The image to be saved
    ///   - imagePath: The image path where the image will be saved
    func saveImage(image:UIImage, imagePath:String) {
        
        //Store image to the temporary folder for later use
        var error: Error?
        
        do {
            var imageToBeSaved:UIImage = image

            if let cacheSize = self.cacheSize,
               !image.size.equalTo(cacheSize) {
                imageToBeSaved = self.resize(image: image, targetSize: cacheSize)
            }
            try imageToBeSaved.pngData()!.write(to: URL(fileURLWithPath: imagePath), options: [])
        } catch let error1 {
            error = error1
            if let actualError = error {
                Swift.debugPrint("Image not saved. \(actualError)")
            }
        }
    }
    
    func readImage(imagePath:String, completion: @escaping (_ error:UIImage?) -> Void) -> Void {
        var image:UIImage?
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                //Image exists
                let dat:Data = imageData
                
                image = UIImage(data:dat)
            }
            completion(image)
    }
    
    //MARK: - Clear cache for specific URLs
    
    /// Clear the storage for specific URLs if they are already downloaded
    ///
    /// - Parameter urls: The urls array for which the storage will be cleared
    public func clearCacheForURLs(urls:Array<String>) -> Void {
        
        for i in stride(from: 0, to: urls.count, by: 1) {
            
            let imgName:String = self.stripURL(url: urls[i])
            
            //Image path
            let imagePath:String = self.storagePathforImageName(name: imgName)
            
            //Check if image exists
            let imageExists:Bool = FileManager.default.fileExists(atPath: imagePath)
            
            if imageExists {
                var error: Error?
                
                do {
                    try FileManager.default.removeItem(atPath: imagePath)
                } catch let error1 {
                    error = error1
                    if let actualError = error {
                        Swift.debugPrint("Image not saved. \(actualError)")
                    }
                }
            }
        }
    }
    
    //MARK - Check image existence
    
    /// Checks if image exists in storage
    ///
    /// - Parameter url: The image URL
    /// - Returns: returns the image path or nil if image does not exists
    func checkIfImageExists(url:String) -> String? {
        
        let imgName:String = self.stripURL(url: url)
        
        //Image path
        var imagePath:String? = self.storagePathforImageName(name: imgName)
        
        //Check if image exists
        let imageExists:Bool = FileManager.default.fileExists(atPath: imagePath!)
        
        if !imageExists {
            imagePath = nil
        }
        
        return imagePath
    }
}
