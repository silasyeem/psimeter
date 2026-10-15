import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count >= 4 else {
    print("usage: swift scripts/brass-tone.swift <in.png> <out.png> <hue-radians> [saturation]")
    exit(2)
}
let input = CIImage(contentsOf: URL(fileURLWithPath: args[1]))!
let hue = Double(args[3])!
let saturation = args.count > 4 ? Double(args[4])! : 1
let shifted = CIFilter(name: "CIHueAdjust", parameters: [kCIInputImageKey: input, kCIInputAngleKey: hue])!.outputImage!
let toned = CIFilter(name: "CIColorControls", parameters: [kCIInputImageKey: shifted, kCIInputSaturationKey: saturation])!.outputImage!
let cg = CIContext().createCGImage(toned, from: input.extent)!
try! NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("wrote \(args[2])")
