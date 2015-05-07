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
    
    private lazy var displayLink:CADisplayLink = CADisplayLink(target: self, selector: "changeKeyFrame:")
    private var accumulator: NSTimeInterval = 0.0
    private var currentFrameIndex: Int = 0
    private var currentFrame: UIImage? = nil
    private var loopCountdown: Int = Int.max
    private var animatedImage: YLGIFImage? = nil
  
    required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    override init(image: UIImage!)  {
        super.init(image: image)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    override init(image: UIImage!, highlightedImage: UIImage!)  {
        super.init(image: image, highlightedImage: highlightedImage)
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink.paused = true
    }
    
    override var image: UIImage! {
        get {
            if (self.animatedImage != nil) {
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
                if let Img = self.animatedImage!.getFrame(0) {
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
        if (self.animatedImage != nil) {
            return
        } else {
            return super.highlighted = newValue
        }
    }
    }
    
    override func isAnimating() -> Bool {
        if (self.animatedImage != nil) {
            return !self.displayLink.paused
        } else {
            return super.isAnimating()
        }
    }
    
    override func startAnimating() {
        if (self.animatedImage != nil) {
            self.displayLink.paused = false
        } else {
            super.startAnimating()
        }
    }
    
    override func stopAnimating()  {
        if (self.animatedImage != nil) {
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
            if self.currentFrameIndex < animatedImg.frameImages.count {
                self.accumulator += fmin(1.0, dpLink.duration)
                var frameDura = animatedImg.frameDurations[self.currentFrameIndex] as! NSNumber
                while self.accumulator >= frameDura.doubleValue
                {
                    self.accumulator = self.accumulator - frameDura.doubleValue//animatedImg.frameDurations[self.currentFrameIndex]
                    self.currentFrameIndex++
                    if Int(self.currentFrameIndex) >= animatedImg.frameImages.count {
                        self.currentFrameIndex = 0
                    }
                    if let Img = animatedImg.getFrame(UInt(self.currentFrameIndex)) {
                        self.currentFrame = Img
                    }
                    self.layer.setNeedsDisplay()
                    frameDura = animatedImg.frameDurations[self.currentFrameIndex] as! NSNumber
                }
                
            }
        } else {
            self.stopAnimating()
        }
    }
}