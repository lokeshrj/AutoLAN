import Cocoa

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    // --- Rounded rect clip ---
    let corner = s * 0.22
    let bgPath = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                        cornerWidth: corner, cornerHeight: corner, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    // --- Background: deep multi-stop radial gradient ---
    let bgColors = [
        CGColor(red: 0.06, green: 0.05, blue: 0.20, alpha: 1.0),  // deep navy
        CGColor(red: 0.10, green: 0.12, blue: 0.35, alpha: 1.0),  // indigo
        CGColor(red: 0.05, green: 0.30, blue: 0.50, alpha: 1.0),  // dark teal
    ] as CFArray
    let bgGrad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 0.5, 1.0])!
    ctx.drawRadialGradient(bgGrad,
                           startCenter: CGPoint(x: s * 0.3, y: s * 0.7),
                           startRadius: 0,
                           endCenter: CGPoint(x: s * 0.5, y: s * 0.5),
                           endRadius: s * 0.85,
                           options: [.drawsAfterEndLocation])

    // --- Ambient glow: top-right warm accent ---
    ctx.saveGState()
    let glowColors = [
        CGColor(red: 0.0, green: 0.85, blue: 0.75, alpha: 0.30),
        CGColor(red: 0.0, green: 0.85, blue: 0.75, alpha: 0.0),
    ] as CFArray
    let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glowGrad,
                           startCenter: CGPoint(x: s * 0.75, y: s * 0.75),
                           startRadius: 0,
                           endCenter: CGPoint(x: s * 0.75, y: s * 0.75),
                           endRadius: s * 0.5,
                           options: [])
    ctx.restoreGState()

    // --- Second glow: bottom-left purple accent ---
    ctx.saveGState()
    let glow2Colors = [
        CGColor(red: 0.45, green: 0.20, blue: 0.80, alpha: 0.25),
        CGColor(red: 0.45, green: 0.20, blue: 0.80, alpha: 0.0),
    ] as CFArray
    let glow2Grad = CGGradient(colorsSpace: colorSpace, colors: glow2Colors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glow2Grad,
                           startCenter: CGPoint(x: s * 0.25, y: s * 0.25),
                           startRadius: 0,
                           endCenter: CGPoint(x: s * 0.25, y: s * 0.25),
                           endRadius: s * 0.5,
                           options: [])
    ctx.restoreGState()

    // --- Flowing arc 1: large sweeping curve (represents wired connection) ---
    ctx.saveGState()
    let arc1 = CGMutablePath()
    arc1.move(to: CGPoint(x: s * -0.05, y: s * 0.35))
    arc1.addCurve(to: CGPoint(x: s * 1.05, y: s * 0.80),
                  control1: CGPoint(x: s * 0.30, y: s * 0.90),
                  control2: CGPoint(x: s * 0.70, y: s * 0.45))

    // Stroke with gradient-like effect using multiple strokes
    for i in (0...4).reversed() {
        let alpha = 0.08 + Double(4 - i) * 0.06
        let width = s * (0.035 - CGFloat(i) * 0.004)
        ctx.setStrokeColor(CGColor(red: 0.0, green: 0.90, blue: 0.80, alpha: alpha))
        ctx.setLineWidth(width)
        ctx.setLineCap(.round)
        ctx.addPath(arc1)
        ctx.strokePath()
    }
    ctx.restoreGState()

    // --- Flowing arc 2: second curve crossing (represents wireless) ---
    ctx.saveGState()
    let arc2 = CGMutablePath()
    arc2.move(to: CGPoint(x: s * 0.15, y: s * -0.05))
    arc2.addCurve(to: CGPoint(x: s * 0.85, y: s * 1.05),
                  control1: CGPoint(x: s * 0.60, y: s * 0.30),
                  control2: CGPoint(x: s * 0.40, y: s * 0.70))

    for i in (0...4).reversed() {
        let alpha = 0.06 + Double(4 - i) * 0.05
        let width = s * (0.030 - CGFloat(i) * 0.003)
        ctx.setStrokeColor(CGColor(red: 0.40, green: 0.60, blue: 1.0, alpha: alpha))
        ctx.setLineWidth(width)
        ctx.setLineCap(.round)
        ctx.addPath(arc2)
        ctx.strokePath()
    }
    ctx.restoreGState()

    // --- Flowing arc 3: thin accent ---
    ctx.saveGState()
    let arc3 = CGMutablePath()
    arc3.move(to: CGPoint(x: s * -0.05, y: s * 0.70))
    arc3.addCurve(to: CGPoint(x: s * 0.70, y: s * 1.05),
                  control1: CGPoint(x: s * 0.20, y: s * 0.55),
                  control2: CGPoint(x: s * 0.50, y: s * 0.85))

    for i in (0...3).reversed() {
        let alpha = 0.05 + Double(3 - i) * 0.04
        let width = s * (0.020 - CGFloat(i) * 0.003)
        ctx.setStrokeColor(CGColor(red: 0.70, green: 0.40, blue: 1.0, alpha: alpha))
        ctx.setLineWidth(width)
        ctx.setLineCap(.round)
        ctx.addPath(arc3)
        ctx.strokePath()
    }
    ctx.restoreGState()

    // --- Central node cluster: intersection point with bright glow ---
    let cx = s * 0.48
    let cy = s * 0.52

    // Outer glow
    ctx.saveGState()
    let nodeGlowColors = [
        CGColor(red: 0.0, green: 1.0, blue: 0.85, alpha: 0.40),
        CGColor(red: 0.0, green: 1.0, blue: 0.85, alpha: 0.0),
    ] as CFArray
    let nodeGlow = CGGradient(colorsSpace: colorSpace, colors: nodeGlowColors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(nodeGlow,
                           startCenter: CGPoint(x: cx, y: cy),
                           startRadius: 0,
                           endCenter: CGPoint(x: cx, y: cy),
                           endRadius: s * 0.15,
                           options: [])
    ctx.restoreGState()

    // Bright center dot
    let dotR = s * 0.038
    ctx.setFillColor(CGColor(red: 0.85, green: 1.0, blue: 0.98, alpha: 0.95))
    ctx.fillEllipse(in: CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2))

    // --- Small satellite dots along curves ---
    let dots: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.22, 0.58, 0.0, 0.90, 0.80, 0.70),   // on arc1
        (0.78, 0.68, 0.0, 0.90, 0.80, 0.60),   // on arc1
        (0.38, 0.22, 0.40, 0.60, 1.0, 0.55),   // on arc2
        (0.62, 0.78, 0.40, 0.60, 1.0, 0.50),   // on arc2
    ]
    for (dx, dy, r, g, b, a) in dots {
        let dr = s * 0.018
        let dotGlowR = s * 0.06
        // Glow
        ctx.saveGState()
        let dGlowColors = [
            CGColor(red: r, green: g, blue: b, alpha: a * 0.5),
            CGColor(red: r, green: g, blue: b, alpha: 0.0),
        ] as CFArray
        let dGlow = CGGradient(colorsSpace: colorSpace, colors: dGlowColors, locations: [0.0, 1.0])!
        ctx.drawRadialGradient(dGlow,
                               startCenter: CGPoint(x: s * dx, y: s * dy),
                               startRadius: 0,
                               endCenter: CGPoint(x: s * dx, y: s * dy),
                               endRadius: dotGlowR,
                               options: [])
        ctx.restoreGState()
        // Dot
        ctx.setFillColor(CGColor(red: r, green: g, blue: b, alpha: a))
        ctx.fillEllipse(in: CGRect(x: s * dx - dr, y: s * dy - dr, width: dr * 2, height: dr * 2))
    }

    // --- Subtle noise/texture overlay for depth ---
    ctx.saveGState()
    ctx.setBlendMode(.softLight)
    for _ in 0..<(size * size / 12) {
        let px = CGFloat.random(in: 0...s)
        let py = CGFloat.random(in: 0...s)
        let brightness = CGFloat.random(in: 0.3...0.7)
        ctx.setFillColor(CGColor(red: brightness, green: brightness, blue: brightness, alpha: 0.015))
        ctx.fill(CGRect(x: px, y: py, width: 1, height: 1))
    }
    ctx.restoreGState()

    image.unlockFocus()
    return image
}

// Generate .iconset
let sizes = [16, 32, 128, 256, 512, 1024]
let iconsetPath = "build/AutoLAN.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try! fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for size in sizes {
    let image = generateIcon(size: size)
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed: \(size)")
        continue
    }
    if size <= 512 {
        try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/icon_\(size)x\(size).png"))
    }
    let half = size / 2
    if half >= 16 {
        try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/icon_\(half)x\(half)@2x.png"))
    }
}
print("Done")
