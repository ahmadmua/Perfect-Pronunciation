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
    
    func updateUserExperience() {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the specified path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let experience = document["Experience"] as? Int,
                       let totalExperience = document["TotalExperience"] as? Int {
                        print("EXPERIENCE CONTROLLER UPDATE: \(experience)")

                        // Prepare the updated data for Experience and TotalExperience
                        let updateData: [String: Any] = [
                            "Experience": experience + 100,
                            "TotalExperience": totalExperience + 100
                        ]

                        //FOR LATER - will make users mroe xp depending on difficulty
                        //                        if(self.model.difficulty == "Easy"){
                        //                            let updateData = ["Currency": value + 50]
                        //
                        //                            // Update the specific field in the user's document
                        //                            userDocRef.updateData(updateData) { error in
                        //                                if let error = error {
                        //                                    print("Error updating document: \(error)")
                        //                                } else {
                        //                                    print("Document updated successfully")
                        //                                }
                        //                            }
                        //
                        //                        }else if(self.model.difficulty == "Intermediate"){
                        //                            let updateData = ["Currency": value + 100]
                        //
                        //                            // Update the specific field in the user's document
                        //                            userDocRef.updateData(updateData) { error in
                        //                                if let error = error {
                        //                                    print("Error updating document: \(error)")
                        //                                } else {
                        //                                    print("Document updated successfully")
                        //                                }
                        //                            }
                        //
                        //                        }else if(self.model.difficulty == "Advanced"){
                        //                            let updateData = ["Currency": value + 150]
                        //
                        //                            // Update the specific field in the user's document
                        //                            userDocRef.updateData(updateData) { error in
                        //                                if let error = error {
                        //                                    print("Error updating document: \(error)")
                        //                                } else {
                        //                                    print("Document updated successfully")
                        //                                }
                        //                            }
                        //                        }
                        
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
        //get reference to database
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Experience"] as? Int {
                        print("Experience CONTROLLER LEVEL : \(value)")
                        
                        //converting to proper level
                        if value >= 500{
                            //get current user level
                            self.getUserLevel()
                            
                            //increase user level
                            self.userCalculatedLevel = self.userLevel + 1
                            
                            //reverting experience and saving to firebase
                            userDocRef.updateData(["Experience": value - 500]){ err in
                                if let err {
                                    print("Error updating document: \(err)")
                                }else{
                                    print("Document successfully updated USERS EXPERIENCE TO 0")
                                }
                            }
                            
                            
                            //saving calculated level to firebase
                            userDocRef.updateData(["ExperienceLevel": self.userCalculatedLevel]){ err in
                                if let err {
                                    print("Error updating document: \(err)")
                                }else{
                                    print("Document successfully updated USERS LEVEL")
                                }
                        }

                        }
                    }else{
                        print("Document exists,")
                        self.userCalculatedLevel = 0
                    }
                }else{
                    print("Document does not exist")
                    self.userCalculatedLevel = 0
                }
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
    
    //MARK: - league system
    
    func demoteUserLeague(){
        
    }
    
    func promoteUserLeague(){
        
    }
    
    
}//class
