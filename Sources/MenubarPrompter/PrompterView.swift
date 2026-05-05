import SwiftUI

struct PrompterView: View {
    @Bindable var store: PrompterStore

    private let sideRadius: CGFloat = 22
    private let bottomRadius: CGFloat = 24

    var body: some View {
        let shape = PrompterBubbleShape(
            wingHeight: store.wingHeight,
            sideRadius: sideRadius,
            bottomRadius: bottomRadius
        )

        ZStack(alignment: .topLeading) {
            shape.fill(Color.black.opacity(0.94))

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !store.isPlaying)) { ctx in
                ScrollingText(store: store, offset: store.currentOffset(at: ctx.date))
            }
            .padding(.top, store.wingHeight + sideRadius)
            .padding(.horizontal, sideRadius + 8)
            .padding(.bottom, bottomRadius / 2)
        }
        .clipShape(shape)
    }
}

struct PrompterBubbleShape: Shape {
    var wingHeight: CGFloat
    var sideRadius: CGFloat
    var bottomRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let bR = max(0, min(bottomRadius, w / 2, h / 2))
        let sR = max(0, min(sideRadius, w / 2 - bR, h / 2))
        let wH = max(0, min(wingHeight, h - sR - bR))

        // Top-left sharp 90° corner.
        p.move(to: CGPoint(x: 0, y: 0))
        // Full-width flat top edge.
        p.addLine(to: CGPoint(x: w, y: 0))
        // Right wing — straight down to where the scoop starts.
        p.addLine(to: CGPoint(x: w, y: wH))
        // Right concave scoop.
        p.addQuadCurve(to: CGPoint(x: w - sR, y: wH + sR),
                       control: CGPoint(x: w - sR, y: wH))
        // Body right edge.
        p.addLine(to: CGPoint(x: w - sR, y: h - bR))
        // Bottom-right convex corner.
        p.addArc(tangent1End: CGPoint(x: w - sR, y: h),
                 tangent2End: CGPoint(x: w - sR - bR, y: h),
                 radius: bR)
        // Bottom edge.
        p.addLine(to: CGPoint(x: sR + bR, y: h))
        // Bottom-left convex corner.
        p.addArc(tangent1End: CGPoint(x: sR, y: h),
                 tangent2End: CGPoint(x: sR, y: h - bR),
                 radius: bR)
        // Body left edge.
        p.addLine(to: CGPoint(x: sR, y: wH + sR))
        // Left concave scoop.
        p.addQuadCurve(to: CGPoint(x: 0, y: wH),
                       control: CGPoint(x: sR, y: wH))
        // Left wing — straight up to the top.
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

private struct ScrollingText: View {
    @Bindable var store: PrompterStore
    let offset: CGFloat

    var body: some View {
        let lines = store.script.components(separatedBy: .newlines)
        let lineHeight = store.fontSize * 1.6
        let currentLineFloat = lineHeight > 0 ? offset / lineHeight : 0

        GeometryReader { geo in
            let centerY = geo.size.height / 2

            VStack(spacing: 0) {
                ForEach(lines.indices, id: \.self) { idx in
                    let relPos = CGFloat(idx) - currentLineFloat
                    Text(lines[idx].isEmpty ? " " : lines[idx])
                        .font(.system(size: store.fontSize, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(opacity(for: relPos)))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity)
                        .frame(height: lineHeight)
                }
            }
            .frame(width: geo.size.width, alignment: .top)
            .offset(y: -offset + centerY - lineHeight / 2)
        }
        .clipped()
        .contentShape(Rectangle())
    }

    private func opacity(for r: CGFloat) -> Double {
        if r < -0.6 {
            return Double(max(0, 0.4 - (-r - 0.6) * 0.5))
        } else if r < 1.4 {
            return 1.0
        } else {
            return Double(max(0, 1.0 - (r - 1.4) * 0.35))
        }
    }
}
