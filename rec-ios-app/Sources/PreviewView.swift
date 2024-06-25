import SwiftUI

final class PreviewUIView: UIView {

    var vertices: [CGPoint]
    var area: CGFloat
    @Binding var uiImage: UIImage?

    init(vertices: [CGPoint], area: CGFloat, uiImage: Binding<UIImage?>) {
        self.vertices = vertices//.map { $0 * 100 }
        self.area = area
        self._uiImage = uiImage

        super.init(frame: .zero)

        backgroundColor = .white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) doesn't implemented")
    }

    override func draw(_ rect: CGRect) {
        guard !vertices.isEmpty else { return }

        let v = transform(forRect: rect)
        let path = UIBezierPath()

        path.move(to: v[0])

        for i in 1..<v.count {
            let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
            let string = NSAttributedString(string: String(format: "%.2fm", vertices[i - 1].distance(to: vertices[i])), attributes: myAttribute)
            string.draw(at: textPoint(point: midPoint(between: v[i - 1], and: v[i]), within: rect))
            path.addLine(to: v[i])
        }
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
        let string = NSAttributedString(string: String(format: "%.2fm", vertices.last!.distance(to: vertices[0])), attributes: myAttribute)
        string.draw(at: textPoint(point: midPoint(between: v.last!, and: v[0]), within: rect))
        let areaString = NSAttributedString(string: String(format: "%.2fm2", area), attributes: myAttribute)
        areaString.draw(at: textPoint(point: rect.center, within: rect))

        path.addLine(to: v[0])
        UIColor.black.set()
        UIColor.black.setFill()
        path.stroke()

        self.uiImage = asImage()
    }
    
    private func transform(forRect rect: CGRect) -> [CGPoint] {
        let indent = CGFloat(0.1)
        let bb = vertices.boudingBox
        let moveTo = rect.origin - bb.origin
        let xScale = (1 / bb.width) * (rect.width * (1 - (indent * 2)))
        let yScale = (1 / bb.height) * (rect.height * (1 - (indent * 2)))

        return vertices.map { v in
            CGPoint(
                x: ((v.x + moveTo.x) * xScale) + (rect.width * indent),
                y: ((v.y + moveTo.y) * yScale) + (rect.height * indent)
            )
        }
    }

    private func midPoint(between first: CGPoint, and second: CGPoint) -> CGPoint {
        CGPoint(
            x: first.x + ((second.x - first.x) / 2),
            y: first.y + ((second.y - first.y) / 2)
        )
    }

    private func textPoint(point: CGPoint, within rect: CGRect) -> CGPoint {
        CGPoint(
            x: point.x + (point.x < (rect.origin.x + (rect.size.width / 2)) ? -30.0 : 10.0),
            y: point.y + (point.y < (rect.origin.y + (rect.size.height / 2)) ? -20.0 : 20.0)
        )
    }
}

extension CGPoint {
    func distance(to destination: CGPoint) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        return CGFloat(sqrt(dx * dx + dy * dy))
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage(frame: CGRect? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: frame ?? bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(
            x: minX + width / 2,
            y: minY + height / 2
        )
    }
}

extension Array where Element == CGPoint {
    var boudingBox: CGRect {
        let xCoordinates = map(\.x)
        let yCoordinates = map(\.y)
        let minX = xCoordinates.min() ?? .zero
        let maxX = xCoordinates.max() ?? .zero
        let minY = yCoordinates.min() ?? .zero
        let maxY = yCoordinates.max() ?? .zero

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    var center: CGPoint {
        var c = CGPoint.zero

        forEach { point in
            c = c + point
        }

        c = c / CGFloat(count)

        return c
    }
}

extension CGPoint {
    func len() -> CGFloat {
        CGFloat(sqrt(powf(Float(x), 2.0) + powf(Float(y), 2.0)))
    }

    static func dot(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
        lhs.x * rhs.x + lhs.y * rhs.y
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }

    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x * rhs.x,
            y: lhs.y * rhs.y
        )
    }

    static func *(lhs: CGPoint, num: Double) -> CGPoint {
        CGPoint(
            x: lhs.x * num,
            y: lhs.y * num
        )
    }

    static func /(lhs: CGPoint, num: CGFloat) -> CGPoint {
        CGPoint(
            x: lhs.x / num,
            y: lhs.y / num
        )
    }

    func dist(to p: CGPoint) -> CGFloat {
        CGFloat(sqrt(powf(Float(x - p.x), 2.0) + powf(Float(y - p.y), 2.0)))
    }
}

struct PreviewView: UIViewRepresentable {

    @Binding var vertices: [CGPoint]
    @Binding var area: CGFloat
    @Binding var uiImage: UIImage?

    func makeUIView(context: Context) -> PreviewUIView {
        PreviewUIView(vertices: vertices, area: area, uiImage: $uiImage)
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        uiView.vertices = vertices
        uiView.area = area
        uiView.setNeedsDisplay()
    }
}
