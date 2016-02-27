//
//  ViewController.swift
//  LazyImage
//
//  Created by Lampros Giampouras on 5/4/15.
//  Copyright (c) 2015 Lampros. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    
    @IBAction func preloadAnImage(sender: AnyObject) {
        self.textField.text = "http://www.keenthemes.com/preview/metronic/theme/assets/global/plugins/jcrop/demos/demo_files/image5.jpg"
    }

    
    @IBAction func loadImage(sender: AnyObject) {
        
        LazyImage.showForImageView(self.imageView, url:self.textField.text!) {
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

