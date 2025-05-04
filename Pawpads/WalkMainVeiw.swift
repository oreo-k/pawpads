import SwiftUI

struct WalkMainView: View {
        @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: true)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                WalkStampGrid()
                Spacer()

                NavigationLink(destination: WalkLogListView()) {
                    Text("View Past Walks")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: WalkGraphView()) {
                    Text("View Walk Graph")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Walking Record")
        }
    }
}
