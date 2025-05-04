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

                Section(header: Text("Your Weight (kg)")) {
                    TextField("ex: 65.0", text: $ownerWeightKg)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Your Dog+ Your Weight(kg)")) {
                    TextField("ex: 78.5", text: $holdingWeightKg)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Your Dog Weigh(kg)")) {
                    TextField("ex: 12.5", text: $weightKg)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    calculateDogWeight()
                }) {
                    Text("Calculate your dog's weight")
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
                    Text("Save Weight")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Weight Record")
            .alert("Saved！", isPresented: $showSaveAlert) {
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
            print("Saved New Weight！")
            weightKg = ""
            ownerWeightKg = ""
        } catch {
            print("Failed to Save...: \(error.localizedDescription)")
        }
    }
}
