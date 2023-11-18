//
//  Difficulty.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import Firebase
import FirebaseAuth
import SwiftUI

struct Difficulty: View {
    @State private var selectedDifficulty: String? = "Intermediate"
    @State private var selection: Int? = nil
    @State var userData = UserData()
    @EnvironmentObject var fireDBHelper: DataHelper
    

    let difficulties = ["Beginner",
        "Intermediate",
        "Advanced."]

    var body: some View {
        VStack{
            
            NavigationLink(destination: Homepage(), tag: 1, selection: self.$selection){}
            
            Text("Select Your Exerience Level")
                .fontWeight(.bold)
                .font(Font.system(size: 40))
                .foregroundColor(Color.yellow)
                .padding(.top, 50)
                .multilineTextAlignment(.center)
            
            List(difficulties, id: \.self, selection: $selectedDifficulty) { difficulty in
                HStack {
                    Text(difficulty)
                    Spacer()
                    if difficulty == selectedDifficulty {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .frame(height: 300)
            
            Spacer()
            
            Text("Depending on your selected proficiency level, our app will curate content tailored to your specific needs and goals")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black)
                .bold()
                .padding(.leading, 10)
                .padding(.trailing, 10)
            
            Spacer()
            
            Button(action: {
                updateData()
            })
            {
                Text("Next")
                    .modifier(CustomTextM(fontName: "", fontSize: 30, fontColor: Color.black))
                
                    .frame(maxWidth: 270)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            
            Spacer()
            
        }
    }
    
//    func updateData(){
//
//        if let user = Auth.auth().currentUser {
//            let userID = user.uid
//            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
//
//            userData.setDifficulty(difficulty: (selectedDifficulty)!)
//
//            let updatedData = ["Difficulty": selectedDifficulty]
//
//            // Update the specific field in the user's document
//            userDocRef.updateData(updatedData as [AnyHashable : Any]) { error in
//                if let error = error {
//                    print("Error updating document: \(error)")
//                } else {
//                    print("Document updated successfully")
//                }
//            }
//        } else {
//            // Handle the case where the user is not authenticated
//        }
//
//        self.selection = 1
//    }
    
    func updateData(){
        fireDBHelper.updateDifficulty(selectedDifficulty: selectedDifficulty!, userData: &userData, selection: &selection)
    }
}


struct Difficulty_Previews: PreviewProvider {
    static var previews: some View {
        Difficulty()
    }
}
