//
//  ViewController.swift
//  YLGIFImageSwiftDemo
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView
    @IBOutlet var button: UIButton
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "YLGIFImage Swift"
        
        YLGIFImage.setPrefetchNum(5)
        
        // Do any additional setup after loading the view, typically from a nib.
        let path = NSBundle.mainBundle().URLForResource("joy", withExtension: "gif").absoluteString
        imageView.image = YLGIFImage(contentsOfFile: path)
        
        if imageView.isAnimating() {
            self.button.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            self.button.setTitle("Play", forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clicked(button:UIButton) {
        
        if imageView.isAnimating() {
            imageView.stopAnimating()
        } else {
            imageView.startAnimating()
        }
        
        if imageView.isAnimating() {
            self.button.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            self.button.setTitle("Play", forState: UIControlState.Normal)
        }
    }

}

