import AppKit
import CoreImage

let args = CommandLine.arguments
let input = CIImage(contentsOf: URL(fileURLWithPath: args[1]))!

func toned(_ points: [(CGFloat, CGFloat)], saturation: CGFloat) -> CIImage {
    var parameters: [String: Any] = [kCIInputImageKey: input]
    for (i, p) in points.enumerated() { parameters["inputPoint\(i)"] = CIVector(x: p.0, y: p.1) }
    let curved = CIFilter(name: "CIToneCurve", parameters: parameters)!.outputImage!
    return CIFilter(name: "CIColorControls", parameters: [kCIInputImageKey: curved, kCIInputSaturationKey: saturation])!.outputImage!
}

let context = CIContext()
func write(_ image: CIImage, _ path: String) {
    let cg = context.createCGImage(image, from: input.extent)!
    try! NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
    print("wrote \(path)")
}

write(toned([(0, 0), (0.2, 0.13), (0.33, 0.235), (0.6, 0.55), (1, 1)], saturation: 1), args[2])
write(toned([(0, 0), (0.2, 0.07), (0.33, 0.12), (0.6, 0.35), (1, 0.85)], saturation: 0.72), args[3])
