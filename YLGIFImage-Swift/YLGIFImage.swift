//
//  YLGIFImage.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

class YLGIFImage : UIImage {

    private lazy var readFrameQueue:dispatch_queue_t = dispatch_queue_create("com.ronnie.gifreadframe", DISPATCH_QUEUE_SERIAL)

    private var _scale:CGFloat = 1.0
    private var _cgImgSource:CGImageSource? = nil
    var totalDuration: NSTimeInterval = 0.0
    var frameDurations = [AnyObject]()
    var loopCount: UInt = 1
    var frameImages:[AnyObject] = [AnyObject]()

    struct YLGIFGlobalSetting {
        static var prefetchNumber:UInt = 10
    }

    class var prefetchNum: UInt {
        return YLGIFGlobalSetting.prefetchNumber
    }

    class func setPrefetchNum(number:UInt) {
        YLGIFGlobalSetting.prefetchNumber = number
    }
//    convenience init(named name: String!) {
//        let path = NSBundle.mainBundle().pathForResource(name, ofType: nil)
//        let data = NSData(contentsOfURL:NSURL.URLWithString(path))
//        self.init(data: data)
//    }

    convenience override init?(contentsOfFile path: String) {
        let data = NSData(contentsOfURL: NSURL(string: path)!)
        self.init(data: data!)
    }

    convenience override init?(data: NSData)  {
        self.init(data: data, scale: 1.0)
    }

    override init?(data: NSData, scale: CGFloat) {
        var cgImgSource = CGImageSourceCreateWithData(data, nil)
        if YLGIFImage.isCGImageSourceContainAnimatedGIF(cgImgSource) {
            super.init()
            createSelf(cgImgSource, scale: scale)
        } else {
            super.init(data: data, scale: scale)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSelf(cgImageSource: CGImageSource!, scale: CGFloat) -> Void {
        _cgImgSource = cgImageSource
        let imageProperties:NSDictionary = CGImageSourceCopyProperties(_cgImgSource, nil) as NSDictionary
        var gifProperties: NSDictionary? = imageProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            self.loopCount = property[kCGImagePropertyGIFLoopCount as String] as! UInt
        }
        let numOfFrames = CGImageSourceGetCount(cgImageSource)
        for i in 0..<numOfFrames {
            // get frame duration
            let frameDuration = YLGIFImage.getCGImageSourceGifFrameDelay(cgImageSource, index: UInt(i))
            self.frameDurations.append(NSNumber(double: frameDuration))
            self.totalDuration += frameDuration

            //println("dura = \(frameDuration)")

            if i < Int(YLGIFImage.prefetchNum) {
                // get frame
                let cgimage = CGImageSourceCreateImageAtIndex(cgImageSource, i, nil)
                var image: UIImage = UIImage(CGImage: cgimage)!
                self.frameImages.append(image)
                //println("\(i): frame = \(image)")
            } else {
                self.frameImages.append(NSNull())
            }
        }
        //println("\(self.frameImages.count)")
    }

    func getFrame(index: UInt) -> UIImage? {
        if Int(index) >= self.frameImages.count {
            return nil
        }
        var image:UIImage? = self.frameImages[Int(index)] as? UIImage
        if self.frameImages.count > Int(YLGIFImage.prefetchNum) {
            if index != 0 {
                self.frameImages[Int(index)] = NSNull()
            }

            for i in index+1...index+YLGIFImage.prefetchNum {
                let idx = Int(i)%self.frameImages.count
                if self.frameImages[idx] is NSNull {
                    dispatch_async(self.readFrameQueue){
                        let cgImg = CGImageSourceCreateImageAtIndex(self._cgImgSource, idx, nil)
                        self.frameImages[idx] = UIImage(CGImage: cgImg!)!
                    }
                }
            }
        }

        return image
    }

    private class func isCGImageSourceContainAnimatedGIF(cgImageSource: CGImageSource!) -> Bool {
        let isGIF:Boolean = UTTypeConformsTo(CGImageSourceGetType(cgImageSource), kUTTypeGIF)
        let imgCount = CGImageSourceGetCount(cgImageSource)
        return isGIF != 0 && imgCount > 1
    }

    private class func getCGImageSourceGifFrameDelay(imageSource: CGImageSourceRef, index: UInt) -> NSTimeInterval {
        var delay = 0.0
        let imgProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, Int(index), nil) as NSDictionary
        let gifProperties:NSDictionary? = imgProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            delay = property[kCGImagePropertyGIFUnclampedDelayTime as String] as! Double
            if delay <= 0 {
                delay = property[kCGImagePropertyGIFDelayTime as String] as! Double
            }
        }
        return delay
    }
}