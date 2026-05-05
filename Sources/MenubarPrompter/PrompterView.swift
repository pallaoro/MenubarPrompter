import SwiftUI

struct PrompterView: View {
    @Bindable var store: PrompterStore

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !store.isPlaying)) { ctx in
            ScrollingText(store: store, offset: store.currentOffset(at: ctx.date))
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.92))
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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
            .padding(.horizontal, 24)
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
