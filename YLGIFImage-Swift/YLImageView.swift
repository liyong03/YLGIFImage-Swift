//
//  YLImageView.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import QuartzCore

class YLImageView : UIImageView {
    
    @lazy var displayLink:CADisplayLink = CADisplayLink(target: self, selector: "changeKeyFrame:")
    var accumulator: NSTimeInterval = 0.0
    var currentFrameIndex: UInt = 0
    var currentFrame: UIImage? = nil
    var loopCountdown: Int = Int.max
    var animatedImage: YLGIFImage? = nil
    
    init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    init(image: UIImage!)  {
        super.init(image: image)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    init(image: UIImage!, highlightedImage: UIImage!)  {
        super.init(image: image, highlightedImage: highlightedImage)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    override var image: UIImage! {
        get {
            if self.animatedImage {
                return self.animatedImage
            } else {
                return super.image
            }
        }
        set{
            if image === newValue {
                return
            }
            self.stopAnimating()
            self.currentFrameIndex = 0
            self.accumulator = 0.0
            
            if newValue is YLGIFImage {
                self.animatedImage = newValue as? YLGIFImage
                let Img = self.animatedImage!.getFrame(0)
                if Img {
                    super.image = Img
                    self.currentFrame = super.image
                }
                self.startAnimating()
            } else {
                super.image = newValue
                self.animatedImage = nil
            }
            self.layer.setNeedsDisplay()
        }
    }
    
    override var highlighted: Bool {
    get{
        return super.highlighted
    }
    set {
        if self.animatedImage {
            return
        } else {
            return super.highlighted = newValue
        }
    }
    }
    
    override func isAnimating() -> Bool {
        if self.animatedImage {
            return !self.displayLink.paused
        } else {
            return super.isAnimating()
        }
    }
    
    override func startAnimating() {
        if self.animatedImage {
            self.displayLink.paused = false
        } else {
            super.startAnimating()
        }
    }
    
    override func stopAnimating()  {
        if self.animatedImage {
            self.displayLink.paused = true
        } else {
            super.stopAnimating()
        }
    }
    
    override func displayLayer(layer: CALayer!) {
        if let animatedImg = self.animatedImage {
            if let frame = self.currentFrame {
                layer.contents = frame.CGImage
            }
        } else {
            return
        }
    }
    
    func changeKeyFrame(dpLink: CADisplayLink!) -> Void {
        if let animatedImg = self.animatedImage {
            if Int(self.currentFrameIndex) < animatedImg.frameImages.count {
                self.accumulator += fmin(10.0, dpLink.duration)
                //println("interval = \(dpLink.duration)")
                while self.accumulator >= animatedImg.frameDurations[Int(self.currentFrameIndex)] {
                    self.accumulator -= animatedImg.frameDurations[Int(self.currentFrameIndex)]
                    self.currentFrameIndex++
                    if Int(self.currentFrameIndex) >= animatedImg.frameImages.count {
                        self.currentFrameIndex = 0
                    }
                    
                    let Img = animatedImg.getFrame(self.currentFrameIndex)
                    if Img {
                        self.currentFrame = Img
                    }
                    self.layer.setNeedsDisplay()
                }
            }
        } else {
            self.stopAnimating()
        }
    }
}