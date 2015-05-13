//
//  ViewController.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


    @IBAction func loadImage(sender: AnyObject) {
        
        LazyImage.showForImageView(self.imageView, url: "http://images2.fanpop.com/image/photos/13200000/Tigers-the-animal-kingdom-13288069-1600-1200.jpg") {
            () in
            //Lazy loading complete. Do something..
        }
    }
    
    
    @IBAction func zoomImage(sender: AnyObject) {
        
        LazyImage.zoomImageView(self.imageView)
    }
    
    
    @IBAction func blurImage(sender: AnyObject) {
        
        LazyImage.blurImageView(self.imageView, style: UIBlurEffectStyle.Light)
    }
}

