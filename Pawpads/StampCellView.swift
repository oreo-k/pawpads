import SwiftUI

struct StampCellView: View {
    let date: Date
    let isWalked: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            if isWalked {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.brown)
            } else {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.2))
            }
        }
        .frame(width: cellSize, height: cellSize)
    }
}
