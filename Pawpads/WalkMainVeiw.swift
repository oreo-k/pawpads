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
                WalkStampGridView()
                Spacer()

                NavigationLink(destination: WalkLogListView()) {
                    Text("過去の散歩記録を見る")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: WalkGraphView()) {
                    Text("散歩量推移グラフを見る")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("散歩記録メニュー")
        }
    }
}
