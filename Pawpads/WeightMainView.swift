import SwiftUI

struct WeightMainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: WeightLogView()) {
                    Text("新しい体重を記録する")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: WeightLogListView()) {
                    Text("過去の体重履歴を見る")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: WeightGraphView()) {
                    Text("体重推移グラフを見る")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("体重管理")
        }
    }
}
