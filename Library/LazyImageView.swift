//
//  LazyImageView.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 01/12/2018.
//

import UIKit

@objc public protocol LazyImageViewDelegate: class {
    
    //Error downloading image
    @objc optional func errorDownloadingImage(url:String) -> Void
}

open class LazyImageView: UIImageView {
    
    /// The delegate
    open weak var delegate: LazyImageViewDelegate?
    
    /// The image url
    open var imageURL:String? {
        didSet {
            self.loaded = false
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    ///The LazyImage object
    lazy var lazyImage:LazyImage = LazyImage()
    
    private var loaded:Bool = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        if (self.frame.size != CGSize.zero) && !self.loaded {
            self.loaded = true

            if let imageURL = self.imageURL {

                //Reset
                self.image = UIImage()

                let newSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)

                //Set default image size ratio
                self.lazyImage.setCacheSize(newSize)

                self.lazyImage.showWithSpinner(imageView:self, url:imageURL) {

                    [weak self] (error:LazyImageError?)  in

                    if let _ = error {
                        self?.delegate?.errorDownloadingImage?(url: imageURL)
                    }
                }
            }
        }
    }
    
    //MARK: - Cancel the request
    
    /// Cancels the image request.
    ///
    /// - Returns: true if there is a valid session
    public func cancelRequest() -> Bool {
        return self.lazyImage.cancel()
    }
}
