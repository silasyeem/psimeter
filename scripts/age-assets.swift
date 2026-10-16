import AppKit

// usage: swift scripts/age-assets.swift <asset.png> <out.png> <brass-texture.png> <steel-texture.png> [strength]
// Brass pixels take detail, mottling, tint and verdigris from the brass texture; neutral pixels take detail and
// freckling from the steel texture. Alpha and geometry are never changed, so aged assets drop in for their originals.

struct Bitmap {
    var w: Int, h: Int, px: [Float]

    init(path: String) {
        guard let cg = NSImage(contentsOfFile: path)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("cannot read \(path)"); exit(1)
        }
        w = cg.width; h = cg.height
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        let ctx = CGContext(data: &bytes, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        px = [Float](repeating: 0, count: w * h * 4)
        for i in 0..<(w * h) {
            let a = Float(bytes[i * 4 + 3]) / 255
            px[i * 4 + 3] = a
            for c in 0..<3 { px[i * 4 + c] = a > 0 ? min(1, Float(bytes[i * 4 + c]) / 255 / a) : 0 }
        }
    }

    func write(_ path: String) {
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        for i in 0..<(w * h) {
            let a = px[i * 4 + 3]
            bytes[i * 4 + 3] = UInt8((a * 255).rounded())
            for c in 0..<3 { bytes[i * 4 + c] = UInt8((min(1, max(0, px[i * 4 + c])) * a * 255).rounded()) }
        }
        let ctx = CGContext(data: &bytes, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        try! NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
            .write(to: URL(fileURLWithPath: path))
    }
}

struct Texture {
    let w: Int, h: Int
    let rgb: [Float]
    let lum: [Float]
    let blur: [Float]
    let mean: (Float, Float, Float)
    let meanLum: Float

    init(path: String, radius: Int) {
        let b = Bitmap(path: path)
        w = b.w; h = b.h
        var rgb = [Float](repeating: 0, count: w * h * 3), lum = [Float](repeating: 0, count: w * h)
        var m: (Float, Float, Float) = (0, 0, 0)
        for i in 0..<(w * h) {
            let r = b.px[i * 4], g = b.px[i * 4 + 1], bl = b.px[i * 4 + 2]
            rgb[i * 3] = r; rgb[i * 3 + 1] = g; rgb[i * 3 + 2] = bl
            lum[i] = 0.299 * r + 0.587 * g + 0.114 * bl
            m.0 += r; m.1 += g; m.2 += bl
        }
        let n = Float(w * h)
        mean = (m.0 / n, m.1 / n, m.2 / n)
        meanLum = 0.299 * mean.0 + 0.587 * mean.1 + 0.114 * mean.2
        self.rgb = rgb; self.lum = lum
        blur = Texture.boxBlur(lum, w: w, h: h, r: radius)
    }

    static func boxBlur(_ src: [Float], w: Int, h: Int, r: Int) -> [Float] {
        var tmp = src, out = src
        for y in 0..<h {
            var acc: Float = 0
            for x in -r...r { acc += src[y * w + ((x % w) + w) % w] }
            for x in 0..<w {
                tmp[y * w + x] = acc / Float(2 * r + 1)
                acc += src[y * w + ((x + r + 1) % w)] - src[y * w + ((x - r) % w + w) % w]
            }
        }
        for x in 0..<w {
            var acc: Float = 0
            for y in -r...r { acc += tmp[((y % h) + h) % h * w + x] }
            for y in 0..<h {
                out[y * w + x] = acc / Float(2 * r + 1)
                acc += tmp[((y + r + 1) % h) * w + x] - tmp[(((y - r) % h + h) % h) * w + x]
            }
        }
        return out
    }

    func index(_ x: Int, _ y: Int, scale: Float) -> Int {
        let tx = Int(Float(x) * scale) % w, ty = Int(Float(y) * scale) % h
        return ty * w + tx
    }
}

let args = CommandLine.arguments
guard args.count >= 5 else { print("usage: swift scripts/age-assets.swift <asset> <out> <brass-tex> <steel-tex> [strength]"); exit(2) }
var asset = Bitmap(path: args[1])
let brass = Texture(path: args[3], radius: 28)
let steel = Texture(path: args[4], radius: 28)
let strength = args.count > 5 ? Float(args[5])! : 1
let scale = 1024 / Float(max(asset.w, asset.h)) * 1.3

func smoothstep(_ a: Float, _ b: Float, _ x: Float) -> Float {
    let t = min(1, max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
}

for y in 0..<asset.h {
    for x in 0..<asset.w {
        let i = (y * asset.w + x) * 4
        if asset.px[i + 3] == 0 { continue }
        var r = asset.px[i], g = asset.px[i + 1], b = asset.px[i + 2]
        let hi = max(r, g, b), lo = min(r, g, b)
        let sat = hi > 0 ? (hi - lo) / hi : 0
        let brassWeight = smoothstep(0.12, 0.28, sat) * smoothstep(0.02, 0.08, r - b)

        let bi = brass.index(x, y, scale: scale), si = steel.index(x, y, scale: scale)
        let bDetail = 1 + 0.55 * strength * (brass.lum[bi] / max(0.02, brass.blur[bi]) - 1)
        let bStain = pow(brass.blur[bi] / max(0.02, brass.meanLum), 0.55 * strength)
        let sDetail = 1 + 0.7 * strength * (steel.lum[si] / max(0.02, steel.blur[si]) - 1)
        let sStain = pow(steel.blur[si] / max(0.02, steel.meanLum), 0.45 * strength)

        var br = r * bDetail * bStain, bg = g * bDetail * bStain, bb = b * bDetail * bStain
        let tint = 0.35 * strength
        br = br * (1 - tint) + br * (brass.rgb[bi * 3] / brass.mean.0) * tint
        bg = bg * (1 - tint) + bg * (brass.rgb[bi * 3 + 1] / brass.mean.1) * tint
        bb = bb * (1 - tint) + bb * (brass.rgb[bi * 3 + 2] / brass.mean.2) * tint
        let verdigris = smoothstep(0.02, 0.10, brass.rgb[bi * 3 + 1] - brass.rgb[bi * 3]) * 0.6 * strength
        let l = 0.299 * br + 0.587 * bg + 0.114 * bb
        br = br * (1 - verdigris) + (l * 0.70) * verdigris
        bg = bg * (1 - verdigris) + (l * 1.05) * verdigris
        bb = bb * (1 - verdigris) + (l * 0.90) * verdigris

        var sr = r * sDetail * sStain, sg = g * sDetail * sStain, sb = b * sDetail * sStain
        let rust = smoothstep(0.04, 0.14, steel.rgb[si * 3] - steel.rgb[si * 3 + 2]) * 0.5 * strength
        sr = sr * (1 - rust) + (sr * 1.35 + 0.05) * rust
        sg = sg * (1 - rust) + (sg * 1.0) * rust
        sb = sb * (1 - rust) + (sb * 0.75) * rust

        r = br * brassWeight + sr * (1 - brassWeight)
        g = bg * brassWeight + sg * (1 - brassWeight)
        b = bb * brassWeight + sb * (1 - brassWeight)
        asset.px[i] = r; asset.px[i + 1] = g; asset.px[i + 2] = b
    }
}
asset.write(args[2])
print("wrote \(args[2]) \(asset.w)x\(asset.h)")
