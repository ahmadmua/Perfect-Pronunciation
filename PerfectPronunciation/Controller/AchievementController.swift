//
//  AchievementController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-11-23.
//

import Foundation
import Firebase

class AchievementController : ObservableObject{
    
    @Published var achievement1: Bool = false
    
    
    func checkUserAchievement(){
        
        
        //Firestore reference
        let firestore = Firestore.firestore()

        // authenticated user
        if let currentUserID = Auth.auth().currentUser?.uid {
            let userDataRef = firestore.collection("UserData").document(currentUserID)
            

            // Read UserData document
            userDataRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    // Access "Achievements" from firebase
                    if let achievements = document.data()?["Achievements"] as? [String: Bool] {
                        
                        print("\(achievements)")
                        // Access individual achievements
                        //achievement 1
                        if let achievement1 = achievements["Achievement 1"] {
                            
                            // Use the achievement data as needed
                            print("Achievement 1: \(achievement1)")
                            print("\(achievement1.description)")
                            if(achievement1.description == "false"){
                                self.achievement1 = true
                                
                            }else if(achievement1.description == "true"){
                                self.achievement1 = false
                            }
                        }

                        // acheivement 2
                    }
                } else {
                    print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            // Handle the case when the user is not authenticated
        }
        
        
    }
    
    func updateUserAchievement(userAchievement: String){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access the "Achievements" from UserData in firebase
                    if var achievements = document.data()?["Achievements"] as? [String: Bool] {
                        
                        if let achievement = achievements[userAchievement] {
                            print("ACHIEVEMENT CONTROLLER UPDATE : \(achievement)")
                            
                            achievements[userAchievement] = true
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(["Achievements" : achievements]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document updated successfully")
                                }
                            }
                            
                        }
                        
                    }else{
                        print("Document exists,")
                        
                    }
                }else{
                    print("Document does not exist")
                    
                }
                
            }
            
            

            
            
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
        }
        
    }
    
    func achievementOneCompletion() -> Bool {
        let convComp = UserDefaults.standard.bool(forKey: "conversationCompleted")
        let direcComp = UserDefaults.standard.bool(forKey: "directionsCompleted")
        let numComp = UserDefaults.standard.bool(forKey: "numbersCompleted")
        let food1Comp = UserDefaults.standard.bool(forKey: "food1Completed")
        let food2Comp = UserDefaults.standard.bool(forKey: "food2Completed")
        
        //check if user completed achievement one
        if(convComp == true && direcComp == true && numComp == true && food1Comp == true && food2Comp == true){
            //send apop up alert
            return true
        }
        return false
        
    }
    
}
