import SwiftUI

struct SettingsView: View {
    @State private var dogName: String = ""
    @State private var birthDate: Date = Date()
    @State private var breed: String = ""
    @State private var gender: String = "オス"
    
    let genders = ["オス", "メス"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("名前")) {
                    TextField("例: Macちゃん", text: $dogName)
                }
                
                Section(header: Text("誕生日")) {
                    DatePicker("誕生日", selection: $birthDate, displayedComponents: .date)
                }
                
                Section(header: Text("犬種")) {
                    TextField("例: フレンチブルドッグ", text: $breed)
                }
                
                Section(header: Text("性別")) {
                    Picker("性別", selection: $gender) {
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
                        Text("プロフィールを保存する")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("設定")
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
        
        print("プロフィール保存完了！")
    }
}
