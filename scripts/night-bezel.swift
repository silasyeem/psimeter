import AppKit
import CoreImage

let args = CommandLine.arguments
let input = CIImage(contentsOf: URL(fileURLWithPath: args[1]))!
let saturation = args.count > 3 ? Double(args[3])! : 0.72
let ceiling = args.count > 4 ? Double(args[4])! : 0.88
let hueShift = args.count > 5 ? Double(args[5])! : 0
let curve = CIFilter(name: "CIToneCurve", parameters: [
    kCIInputImageKey: input,
    "inputPoint0": CIVector(x: 0.0, y: 0.0),
    "inputPoint1": CIVector(x: 0.25, y: 0.13),
    "inputPoint2": CIVector(x: 0.5, y: 0.3),
    "inputPoint3": CIVector(x: 0.75, y: 0.52 * ceiling / 0.88),
    "inputPoint4": CIVector(x: 1.0, y: ceiling),
])!.outputImage!
let muted = CIFilter(name: "CIColorControls", parameters: [
    kCIInputImageKey: curve,
    kCIInputSaturationKey: saturation,
    kCIInputBrightnessKey: 0.0,
    kCIInputContrastKey: 1.0,
])!.outputImage!
let shifted = hueShift == 0 ? muted : CIFilter(name: "CIHueAdjust", parameters: [kCIInputImageKey: muted, kCIInputAngleKey: hueShift])!.outputImage!
let context = CIContext()
let cg = context.createCGImage(shifted, from: input.extent)!
let png = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: args[2]))
print("wrote \(args[2])")
