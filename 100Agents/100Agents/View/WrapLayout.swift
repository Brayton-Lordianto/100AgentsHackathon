
import SwiftUI

struct WrapLayout: Layout {
    var verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for size in sizes {
            if currentRowWidth + size.width > proposal.width ?? .infinity {
                totalHeight += currentRowHeight + verticalSpacing
                currentRowWidth = 0
                currentRowHeight = 0
            }
            currentRowWidth += size.width
            currentRowHeight = max(currentRowHeight, size.height)
            totalWidth = max(totalWidth, currentRowWidth)
        }
        totalHeight += currentRowHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentRowHeight: CGFloat = 0

        for index in subviews.indices {
            let size = sizes[index]
            if currentX + size.width > bounds.width {
                currentX = bounds.minX
                currentY += currentRowHeight + verticalSpacing
                currentRowHeight = 0
            }
            subviews[index].place(at: CGPoint(x: currentX, y: currentY), anchor: .topLeading, proposal: .unspecified)
            currentX += size.width
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}
