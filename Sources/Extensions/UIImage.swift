import UIKit

extension UIImage {
    
    func averageColor() -> UIColor? {
        // https://stackoverflow.com/questions/26330924
        guard let ciImage = ciImage ?? CIImage(image: self) else { return nil }

        // CIAreaAverage returns a single-pixel image that contains the average color for a given region of an image.
        let parameters = [kCIInputImageKey: ciImage, kCIInputExtentKey: CIVector(cgRect: ciImage.extent)]
        guard let outputImage = CIFilter(name: "CIAreaAverage", parameters: parameters)?.outputImage else {
            return nil
        }

        // After getting the single-pixel image from the filter extract pixel's RGBA8 data
        var bitmap = [UInt8](repeating: 0, count: 4)
        let workingColorSpace: Any = cgImage?.colorSpace ?? NSNull()
        let context = CIContext(options: [.workingColorSpace: workingColorSpace])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        // Convert pixel data to UIColor
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
    }
}
