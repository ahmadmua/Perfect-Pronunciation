//
//  ExperienceController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-10-13.
//

import Foundation
import Firebase

class ExperienceController: ObservableObject {
    @Published var userXp: Int = 0
    @Published var userTotalXp: Int = 0
    @Published var userCalculatedLevel: Int = 0
    @Published var userLevel: Int = 0
    @Published var difficulty: String?
    
    init() {
            getUserExperience()
            getUserLevel()
        }
    
    func getUserExperience(){
        //get reference to database
        //        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Experience"] as? Int {
                        print("Experience CONTROLLER : \(value)")
                        
                        //converting to proper experience
                        self.userXp = value
                        
                        
                    }else{
                        print("Document exists,")
                        self.userXp = 0
                    }
                }else{
                    print("Document does not exist")
                    self.userXp = 0
                }
            }
        }
    }
    
    func getTotalUserExperience(){
        //get reference to database
        //        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["TotalExperience"] as? Int {
                        print("Experience CONTROLLER : \(value)")
                        
                        //converting to proper experience
                        self.userTotalXp = value
                        
                        
                    }else{
                        print("Document exists,")
                        self.userTotalXp = 0
                    }
                }else{
                    print("Document does not exist")
                    self.userTotalXp = 0
                }
            }
        }
    }
    
    func updateUserExperience(difficulty: String) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the specified path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let experience = document["Experience"] as? Int,
                       let totalExperience = document["TotalExperience"] as? Int {
                        print("EXPERIENCE CONTROLLER UPDATE: \(experience)")
                        
                        //Experience based on difficulty
                        let baseExperience = 100
                        var experienceGain = baseExperience
                        
                        switch difficulty {
                        case "Beginner":
                            experienceGain = baseExperience
                        case "Intermediate":
                            experienceGain = baseExperience * 2
                        case "Advanced":
                            experienceGain = baseExperience * 3
                        default:
                            print("Unknown difficulty level. Using base experience.")
                        }
                        
                        // Prepare the updated data for Experience and TotalExperience
                        let updateData: [String: Any] = [
                            "Experience": experience + experienceGain,
                            "TotalExperience": totalExperience + experienceGain
                        ]
                                                
                        // Update the fields in the user's document
                        userDocRef.updateData(updateData) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                self.calculateUserLevel()
                                print("Document updated successfully with new Experience and TotalExperience")
                            }
                        }
                    } else {
                        print("Failed to retrieve Experience or TotalExperience from document")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
        }
    }
    
    
    
    
    //MARK: -  LEVEL SYSTEM
    
    func calculateUserLevel() {
        guard let user = Auth.auth().currentUser else { return }
        let userID = user.uid
        let userDocRef = Firestore.firestore().collection("UserData").document(userID)

        userDocRef.getDocument { document, error in
            if let document = document, document.exists,
               let currentXP = document["Experience"] as? Int,
               let currentLevel = document["ExperienceLevel"] as? Int {

                if currentXP >= 500 {
                    let newXP = currentXP - 500
                    let newLevel = currentLevel + 1

                    // Update both XP and level in Firebase
                    userDocRef.updateData([
                        "Experience": newXP,
                        "ExperienceLevel": newLevel
                    ]) { error in
                        if let error = error {
                            print("Error updating level: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                self.userXp = newXP
                                self.userLevel = newLevel
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist or is missing fields")
            }
        }
    }

    
    
    func getUserLevel(){
        //get reference to database
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["ExperienceLevel"] as? Int {
                        print("Experience CONTROLLER LEVEL GET: \(value)")
                        
                        //converting to proper experience
                        self.userLevel = value
                        
                        
                    }else{
                        print("Document exists,")
                        self.userLevel = 0
                    }
                }else{
                    print("Document does not exist")
                    self.userLevel = 0
                }
            }
        }
    }
    
    func getUserDifficultyForRewards(completion: @escaping (String?) -> Void) {
        // Get reference to database
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let value = document["Difficulty"] as? String {
                        print("LESSON CONTROLLER : \(value)")
                        
                        // Converting to proper difficulty
                        switch value {
                        case "Beginner", "Intermediate", "Advanced":
                            completion(value) // Return the value through the completion handler
                        default:
                            completion(nil) // Handle unexpected values
                        }
                    } else {
                        print("Document exists but Difficulty field is missing")
                        completion(nil)
                    }
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        } else {
            print("No authenticated user")
            completion(nil)
        }
    }

    
    
}//class
