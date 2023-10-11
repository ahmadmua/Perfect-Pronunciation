import SwiftUI
import Firebase
import FirebaseAuth

struct Country: View {
    
    var countriesData: [(name: String, flag: String)] = []
    @State private var selectedCountry: String = ""
    @State private var selection: Int? = nil
    
    init() {
        for code in NSLocale.isoCountryCodes {
            let flag = String.emojiFlag(for: code)
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            
            if let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) {
                countriesData.append((name: name, flag: flag ?? ""))
            }
        }
    }
    
    var body: some View {
        
        VStack {
            
            NavigationLink(destination: Difficulty(), tag: 1, selection: self.$selection){}
            
            Text("Select Your Nationality")
                .fontWeight(.bold)
                .font(Font.system(size: 40))
                .foregroundColor(Color.yellow)
                .padding(.bottom, 30)
            
            Picker("Select a Country", selection: $selectedCountry) {
                ForEach(countriesData, id: \.name) { country in
                    Text("\(country.flag) \(country.name)")
                        .tag(country.name)
                }
            }
            .pickerStyle(WheelPickerStyle()) // You can choose a different style if you prefer
            
            
            Button(action: {
                self.selection = 1
               updateData()

            })
            {
                Text("Next")
                    .modifier(CustomTextM(fontName: "", fontSize: 30, fontColor: Color.black))
                
                    .frame(maxWidth: 270)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding(.top, 100)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func updateData(){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)

            // Define the data you want to update
            let updatedData = ["Country": selectedCountry]

            // Update the specific field in the user's document
            userDocRef.updateData(updatedData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document updated successfully")
                }
            }
        } else {
            // Handle the case where the user is not authenticated
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    static func emojiFlag(for countryCode: String) -> String? {
        func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
            return scalar.value >= 0x61 && scalar.value <= 0x7A
        }

        func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
            precondition(isLowercaseASCIIScalar(scalar))

            // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
            // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
            return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
        }

        let lowercasedCode = countryCode.lowercased()
        guard lowercasedCode.count == 2 else { return nil }
        guard lowercasedCode.unicodeScalars.reduce(true, { accum, scalar in accum && isLowercaseASCIIScalar(scalar) }) else { return nil }

        let indicatorSymbols = lowercasedCode.unicodeScalars.map({ regionalIndicatorSymbol(for: $0) })
        return String(indicatorSymbols.map({ Character($0) }))
    }
}
