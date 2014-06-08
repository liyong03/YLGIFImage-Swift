//
//  YLGIFImage.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import imageIO
import MobileCoreServices

class YLGIFImage : UIImage {
    var _scale:CGFloat = 1.0
    var _cgImgSource:CGImageSource? = nil
    var totalDuration: NSTimeInterval = 0.0;
    var frameDurations = NSTimeInterval[]()
    var loopCount: UInt = 1
    var frameImages:UIImage[] = UIImage[]()
    
//    convenience init(named name: String!) {
//        let path = NSBundle.mainBundle().pathForResource(name, ofType: nil)
//        let data = NSData(contentsOfURL:NSURL.URLWithString(path))
//        self.init(data: data)
//    }
    
    convenience init(contentsOfFile path: String!) {
        let data = NSData(contentsOfURL: NSURL.URLWithString(path))
        self.init(data: data)
    }
    
    convenience init(data: NSData!)  {
        self.init(data: data, scale: 1.0)
    }
    
    init(data: NSData!, scale: CGFloat) {
        var cgImgSource = CGImageSourceCreateWithData(data, nil).takeRetainedValue()
        if YLGIFImage.isCGImageSourceContainAnimatedGIF(cgImgSource) {
            super.init()
            createSelf(cgImgSource, scale: scale)
        } else {
            super.init(data: data, scale: scale)
        }
    }
    
    func createSelf(cgImageSource: CGImageSource!, scale: CGFloat) -> Void {
        _cgImgSource = cgImageSource
        let imageProperties:NSDictionary = CGImageSourceCopyProperties(_cgImgSource, nil).takeRetainedValue() as NSDictionary
        var gifProperties: NSDictionary? = imageProperties[kCGImagePropertyGIFDictionary] as? NSDictionary
        if let property = gifProperties {
            self.loopCount = property[kCGImagePropertyGIFLoopCount] as UInt
        }
        let numOfFrames = CGImageSourceGetCount(cgImageSource)
        for i in 0..numOfFrames {
            // get frame duration
            let frameDuration = YLGIFImage.getCGImageSourceGifFrameDelay(cgImageSource, index: i);
            self.frameDurations.append(frameDuration)
            self.totalDuration += frameDuration;
            
            //println("dura = \(frameDuration)")
            
            // get frame
            let cgimage = CGImageSourceCreateImageAtIndex(cgImageSource, i, nil).takeRetainedValue();
            var image:UIImage = UIImage(CGImage: cgimage)
            self.frameImages.append(image)
            //println("\(i): frame = \(image)")
        }
        println("\(self.frameImages.count)")
    }
    
    class func isCGImageSourceContainAnimatedGIF(cgImageSource: CGImageSource!) -> Bool {
        let isGIF:Boolean = UTTypeConformsTo(CGImageSourceGetType(cgImageSource).takeUnretainedValue(), kUTTypeGIF)
        let imgCount = CGImageSourceGetCount(cgImageSource)
        return isGIF != 0 && imgCount > 1
    }
    
    class func getCGImageSourceGifFrameDelay(imageSource: CGImageSourceRef, index: UInt) -> NSTimeInterval {
        var delay = 0.0
        let imgProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil).takeRetainedValue() as NSDictionary
        let gifProperties:NSDictionary? = imgProperties[kCGImagePropertyGIFDictionary] as? NSDictionary
        if let property = gifProperties {
            delay = property[kCGImagePropertyGIFUnclampedDelayTime] as Double
            if delay <= 0 {
                delay = property[kCGImagePropertyGIFDelayTime] as Double
            }
        }
        return delay
    }
}