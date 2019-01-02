//
//  ViewController.swift
//  LazyImageExampleApp
//
//  Created by Lampros Giampouras on 31/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import LazyImage

class ViewController: UIViewController {
    
    lazy var lazyImage = LazyImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let imageView:UIImageView = self.addAnImageview()
        
        //Test image URL. Change with a valid one.
        let imageURL = "https://images.unsplash.com/photo-1506145953600-ed38ef5a186d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"
        
        //Clear the cache to test download again
        self.lazyImage.clearCacheForURLs(urls: [imageURL])
        
        //Downlod the image
        self.lazyImage.showWithSpinner(imageView: imageView, url: imageURL) {
            (error:LazyImageError?) in
            
            //Image loaded. Do something..
        }
    }
    
    //MARK: - Helper methods
    
    private func addAnImageview() -> UIImageView {
        let imageView:UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        self.pinEdges(for: imageView, to: self.view)
        return imageView
    }

    private func pinEdges(for current: UIView, to other: UIView) {
        current.leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        current.trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        current.topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        current.bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}

