import SwiftUI

struct PrompterView: View {
    @Bindable var store: PrompterStore

    // Top edge spans the full width; the concave scoops cut INWARD on each
    // side, transitioning down to a narrower body. The scoop height equals
    // sideRadius — there is no straight section above it.
    private let sideRadius: CGFloat = 22
    private let bottomRadius: CGFloat = 24

    var body: some View {
        let shape = PrompterBubbleShape(
            sideRadius: sideRadius,
            bottomRadius: bottomRadius
        )

        ZStack(alignment: .topLeading) {
            shape.fill(Color.black.opacity(0.94))

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !store.isPlaying)) { ctx in
                ScrollingText(store: store, offset: store.currentOffset(at: ctx.date))
            }
            .padding(.top, sideRadius)
            .padding(.horizontal, sideRadius + 8)
            .padding(.bottom, bottomRadius / 2)
        }
        .clipShape(shape)
    }
}

struct PrompterBubbleShape: Shape {
    var sideRadius: CGFloat
    var bottomRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let bR = max(0, min(bottomRadius, w / 2, h / 2))
        let sR = max(0, min(sideRadius, w / 2 - bR, h / 2))

        // Top-left sharp 90° corner.
        p.move(to: CGPoint(x: 0, y: 0))
        // Full-width flat top edge.
        p.addLine(to: CGPoint(x: w, y: 0))
        // Right concave scoop — curve cuts inward from the corner down to the
        // narrower body. Control at the far end of the top edge so the tangent
        // arrives vertically at the body's right edge.
        p.addQuadCurve(to: CGPoint(x: w - sR, y: sR),
                       control: CGPoint(x: w - sR, y: 0))
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
        p.addLine(to: CGPoint(x: sR, y: sR))
        // Left concave scoop — mirror of the right.
        p.addQuadCurve(to: CGPoint(x: 0, y: 0),
                       control: CGPoint(x: sR, y: 0))
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
