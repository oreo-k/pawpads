//
//  WeighLogView.swift
//  Pawpads
//
//  Created by REO KOSAKA on 4/26/25.
//

import SwiftUI
import CoreData

struct WeightLogView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var weightKg: String = ""
    @State private var ownerWeightKg: String = ""

    @State private var showSaveAlert = false

    @State private var holdingWeightKg: String = ""

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("飼い主の体重（kg, 任意）")) {
                    TextField("例: 65.0", text: $ownerWeightKg)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("抱っこした時の体重（kg）")) {
                    TextField("例: 78.5", text: $holdingWeightKg)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("愛犬の体重（kg）")) {
                    TextField("例: 12.5", text: $weightKg)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    calculateDogWeight()
                }) {
                    Text("犬の体重を計算する")
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    saveWeightLog()
                    showSaveAlert = true
                }) {
                    Text("体重を保存する")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("体重記録")
            .alert("保存しました！", isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func calculateDogWeight() {
        if let holding = Double(holdingWeightKg), let owner = Double(ownerWeightKg) {
            let dogWeight = holding - owner
            weightKg = String(format: "%.2f", dogWeight)
        }
    }

    private func saveWeightLog() {
        let newLog = WeightLog(context: viewContext)
        newLog.date = Date()
        
        if let weight = Double(weightKg) {
            newLog.weightKg = weight
            newLog.weightLbs = weight * 2.20462
        }
        
        if let ownerWeight = Double(ownerWeightKg) {
            newLog.ownerWeightKg = ownerWeight
            newLog.ownerWeightLbs = ownerWeight * 2.20462
        }

        do {
            try viewContext.save()
            print("体重記録保存完了！")
            weightKg = ""
            ownerWeightKg = ""
        } catch {
            print("保存エラー: \(error.localizedDescription)")
        }
    }
}
