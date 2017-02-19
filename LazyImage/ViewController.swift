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
    
    //The lazy image object
    lazy var lazyImage:LazyImage = LazyImage()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    
    @IBAction func preloadAnImage(_ sender: AnyObject) {
        self.textField.text = "https://pbs.twimg.com/media/CjfGZJvUoAUSLrx.jpg"
    }

    
    @IBAction func loadImage(_ sender: AnyObject) {
        
        self.lazyImage.showWithSpinner(imageView:self.imageView, url:self.textField.text!) {
            () in
            //Lazy loading complete. Do something..
        }
    }
    
    
    @IBAction func zoomImage(_ sender: AnyObject) {
        
        self.lazyImage.zoom(imageView:self.imageView)
    }
    
    
    @IBAction func blurImage(_ sender: AnyObject) {
        
        let _ = self.lazyImage.blur(imageView:self.imageView, style: UIBlurEffectStyle.light)
    }
}

