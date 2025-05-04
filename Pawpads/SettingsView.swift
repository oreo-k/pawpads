import SwiftUI

struct SettingsView: View {
    @State private var dogName: String = ""
    @State private var birthDate: Date = Date()
    @State private var breed: String = ""
    @State private var gender: String = "Male"
    
    let genders = ["Male", "Female"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("ex) Mac", text: $dogName)
                }
                
                Section(header: Text("Date Birth")) {
                    DatePicker("Date Birth", selection: $birthDate, displayedComponents: .date)
                }
                
                Section(header: Text("Breed")) {
                    TextField("ex) French Bulldog", text: $breed)
                }
                
                Section(header: Text("Sex")) {
                    Picker("Sex", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Save Profile")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Setting")
            .onAppear {
                loadProfile()
            }
        }
    }
    private func loadProfile() {
        if let savedName = UserDefaults.standard.string(forKey: "dogName") {
            dogName = savedName
        }
        if let savedBirthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date {
            birthDate = savedBirthDate
        }
        if let savedBreed = UserDefaults.standard.string(forKey: "breed") {
            breed = savedBreed
        }
        if let savedGender = UserDefaults.standard.string(forKey: "gender") {
            gender = savedGender
        }
    }

    
    private func saveProfile() {
        UserDefaults.standard.set(dogName, forKey: "dogName")
        UserDefaults.standard.set(birthDate, forKey: "birthDate")
        UserDefaults.standard.set(breed, forKey: "breed")
        UserDefaults.standard.set(gender, forKey: "gender")
        
        print("Complete Saving!")
    }
}
