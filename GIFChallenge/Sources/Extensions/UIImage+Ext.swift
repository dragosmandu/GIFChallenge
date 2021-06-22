import UIKit

extension UIImage
{
    static func animatedImageWith(imageSource: CGImageSource) -> UIImage?
    {
        let count = CGImageSourceGetCount(imageSource)
        var delay = 0.1
        
        if let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?
        {
            if let delayTime = properties[kCGImagePropertyGIFDictionary as NSString]?[kCGImagePropertyGIFDelayTime as NSString]
            {
                if let delayTime = delayTime as? NSNumber
                {
                    delay = Double(truncating: delayTime)
                }
            }
        }
        
        var frames = [UIImage]()
        let duration = Double(count) * delay
        
        for index in 0..<count
        {
            if let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            {
                let frame = UIImage(cgImage: image)
                frames.append(frame)
            }
        }
        
        let animatedImage = UIImage.animatedImage(with: frames, duration: duration)
        
        return animatedImage
    }
}
