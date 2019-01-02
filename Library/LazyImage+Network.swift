//
//  LazyImage+Network.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 02/01/2019.
//

extension LazyImage {

    //MARK: - Call
    
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
            
            let session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
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
            task.resume()
        })
    }
}
