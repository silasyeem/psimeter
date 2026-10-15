import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else {
    print("usage: swift scripts/chroma-key.swift <in.png> <out.png> [--crop]")
    exit(2)
}
let crop = args.contains("--crop")

guard let source = NSImage(contentsOfFile: args[1]),
      let cg = source.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("cannot read \(args[1])")
    exit(1)
}

let width = cg.width, height = cg.height
var pixels = [UInt8](repeating: 0, count: width * height * 4)
let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

// Greenness = how far green exceeds the brighter of red and blue; ramps alpha out between the two thresholds.
let opaqueBelow = 0.12, clearAbove = 0.38
var minX = width, minY = height, maxX = -1, maxY = -1
for y in 0..<height {
    for x in 0..<width {
        let i = (y * width + x) * 4
        let r = Double(pixels[i]) / 255, g = Double(pixels[i + 1]) / 255, b = Double(pixels[i + 2]) / 255
        let greenness = g - max(r, b)
        let alpha = min(1, max(0, (clearAbove - greenness) / (clearAbove - opaqueBelow)))
        let despilledG = min(g, max(r, b) + 0.02)
        pixels[i] = UInt8((r * alpha * 255).rounded())
        pixels[i + 1] = UInt8((despilledG * alpha * 255).rounded())
        pixels[i + 2] = UInt8((b * alpha * 255).rounded())
        pixels[i + 3] = UInt8((alpha * 255).rounded())
        if alpha > 0.5 {
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
        }
    }
}

var keyed = context.makeImage()!
if crop, maxX >= minX, maxY >= minY {
    keyed = keyed.cropping(to: CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1))!
}
let png = NSBitmapImageRep(cgImage: keyed).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: args[2]))
print("wrote \(args[2]) \(keyed.width)x\(keyed.height)")
