//
//  LazyImage+Network.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 02/01/2019.
//

extension LazyImage {

    //MARK: - Call
    
    /// Method for fetching the image for a specific URL.
    ///
    /// - Parameters:
    ///   - url: The corresponding URL of the image
    ///   - completion: Closure with the image or error if any
    public func fetchImage(url:String?, completion: @escaping (_ image:UIImage?, _ error:LazyImageError?) -> Void) -> Void {
        
        guard let url = url else {
            
            //Call did not succeed
            let error: LazyImageError = LazyImageError.CallFailed
            completion(nil, error)
            return
        }
        
        //Lazy load image (Asychronous call)
        let urlObject:URL = URL(string:url)!
        let urlRequest:URLRequest = URLRequest(url: urlObject)
        
        let backgroundQueue = DispatchQueue(label:"imageBackgroundQue",
                                            qos: .background,
                                            target: nil)
        
        backgroundQueue.async(execute: {
            
            self.session = URLSession(configuration: URLSessionConfiguration.default)
            let task = self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                if response != nil {
                    let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode != 200 {
                        Swift.debugPrint("LazyImage status code : \(httpResponse.statusCode)")
                        
                        //Completion block
                        //Call did not succeed
                        let error: LazyImageError = LazyImageError.CallFailed
                        completion(nil, error)
                        return
                    }
                }
                
                if data == nil {
                    if error != nil {
                        Swift.debugPrint("Error : \(error!.localizedDescription)")
                    }
                    Swift.debugPrint("LazyImage: No image data available")
                    
                    //No data available
                    let error: LazyImageError = LazyImageError.noDataAvailable
                    completion(nil, error)
                    return
                }
                
                completion(UIImage(data:data!), nil)
                return
            })
            task?.resume()
        })
    }
    
    //MARK: - Cancel session
    
    /// Cancels the image request.
    ///
    /// - Returns: true if there is a valid session
    public func cancel() -> Bool {
        
        guard let _ = self.session else {
            return false
        }

        self.showSpinner = false
        self.forceDownload = false
        self.spinner = nil
        self.desiredImageSize = nil

        self.session?.invalidateAndCancel()
        self.session = nil
        return true
    }
}
