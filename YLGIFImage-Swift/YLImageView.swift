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
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    init(image: UIImage!)  {
        super.init(image: image)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    init(image: UIImage!, highlightedImage: UIImage!)  {
        super.init(image: image, highlightedImage: highlightedImage)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
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
                self.animatedImage = newValue as? YLGIFImage;
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
        return super.isAnimating() && !self.displayLink.paused
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
        if animatedImage {
            if self.currentFrame {
                layer.contents = self.currentFrame!.CGImage
            }
        } else {
            return
        }
    }
    
    func changeKeyFrame(dpLink: CADisplayLink!) -> Void {
        if !self.animatedImage {
            self.stopAnimating()
            return
        }
        if Int(self.currentFrameIndex) >= self.animatedImage!.frameImages.count {
            return
        } else {
            self.accumulator += fmin(1.0, dpLink.duration)
            while self.accumulator >= self.animatedImage!.frameDurations[Int(self.currentFrameIndex)] {
                self.accumulator -= self.animatedImage!.frameDurations[Int(self.currentFrameIndex)]
                self.currentFrameIndex++
                if Int(self.currentFrameIndex) >= self.animatedImage!.frameImages.count {
                    self.currentFrameIndex = 0
                }
                
                let Img = self.animatedImage!.getFrame(self.currentFrameIndex)
                if Img {
                    self.currentFrame = Img
                }
                self.layer.setNeedsDisplay()
            }
        }
    }
}