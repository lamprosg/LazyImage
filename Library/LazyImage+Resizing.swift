//
//  LazyImage+Resizing.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 02/01/2019.
//
//Image resizing techniques
//https://nshipster.com/image-resizing/
//Optimizing images
//https://www.swiftjectivec.com/optimizing-images/

extension LazyImage {
    
    //MARK: - Resize image
    
    func resize(image: UIImage, targetSize: CGSize) -> UIImage {

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
}
