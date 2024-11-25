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
    @Published var achievement2: Bool = false
    @Published var achievement3: Bool = false
    @Published var achievement4: Bool = false
    @Published var achievement5: Bool = false
    
    
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
                        if let achievement2 = achievements["Achievement 2"] {
                            
                            // Use the achievement data as needed
                            print("Achievement 2: \(achievement2)")
                            print("\(achievement2.description)")
                            if(achievement2.description == "false"){
                                self.achievement2 = true
                                
                            }else if(achievement2.description == "true"){
                                self.achievement2 = false
                            }
                        }
                        
                        // acheivement 3
                        if let achievement3 = achievements["Achievement 3"] {
                            
                            // Use the achievement data as needed
                            print("Achievement 3: \(achievement3)")
                            print("\(achievement3.description)")
                            if(achievement3.description == "false"){
                                self.achievement3 = true
                                
                            }else if(achievement3.description == "true"){
                                self.achievement3 = false
                            }
                        }
                        
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
    
    func UpdateAchievementCompletionCheck(userAchievement: String){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access the "AchievementsCHeck" from UserData in firebase
                    if var achievementsCheck = document.data()?["AchievementsCheck"] as? [String: Bool] {
                        
                        if let achievement = achievementsCheck[userAchievement] {
                            print("ACHIEVEMENT CONTROLLER UPDATE : \(achievement)")
                            
                            achievementsCheck[userAchievement] = true
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(["AchievementsCheck" : achievementsCheck]) { error in
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
    
    
    func checkAchievementCompletion(userAchievement: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
            completion(false)
            return
        }
        
        let userID = user.uid
        let userDocRef = Firestore.firestore().collection("UserData").document(userID)
        
        // Read the document from Firestore
        userDocRef.getDocument { document, error in
            if let error = error {
                // Handle the error 
                print("Error getting document: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let document = document, document.exists else {
                // Handle the case where the document does not exist
                print("Document does not exist")
                completion(false)
                return
            }
            
            // Access the "AchievementsCheck" dictionary from UserData in Firestore
            if let achievementsCheck = document.data()?["AchievementsCheck"] as? [String: Bool] {
                // Check if the specified achievement is marked as true
                let achievementChecked = achievementsCheck[userAchievement] == true
                completion(achievementChecked)
            } else {
                // Handle the case where AchievementsCheck is not found or is in an unexpected format
                print("AchievementsCheck data is not available or is in an unexpected format")
                completion(false)
            }
        }
    }

    
    
    //complete all lessons
    func achievementOneCompletion(completion: @escaping (Bool) -> Void) {
        // Check if a user is logged in
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the user's path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    // Access the LessonsCompleted field
                    if let lessonsCompleted = document["LessonsCompleted"] as? [String: Bool] {
                        // Check if all required lessons are completed
                        let allCompleted = lessonsCompleted["Conversation"] == true &&
                                           lessonsCompleted["Directions"] == true &&
                                           lessonsCompleted["Food1"] == true &&
                                           lessonsCompleted["Food2"] == true &&
                                           lessonsCompleted["Numbers"] == true
                        
                        // Pass the result to the completion handler
                        completion(allCompleted)
                    } else {
                        print("LessonsCompleted field is missing or not in the expected format.")
                        completion(false)
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)
                }
            }
        } else {
            print("No user is logged in.")
            completion(false)
        }
    }
    
    
    //Reach Level 5
    func achievementLevelCompletion(completion: @escaping (Bool) -> Void) {
        // Check if a user is logged in
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the users path
            userDocRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    completion(false)
                    return
                }
                
                if let document = document, document.exists {
                    // ExperienceLevel field
                    if let xpLevel = document["ExperienceLevel"] as? Int {
                        // Check if user reached level 5
                        completion(xpLevel >= 5)
                    } else {
                        print("ExperienceLevel field is missing or not in the expected format.")
                        completion(false)
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)
                }
            }
        } else {
            print("No user is logged in.")
            completion(false)
        }
    }

    
    //Participate/complete Weekly Lesson
    func achievementWeeklyCompletion(completion: @escaping (Bool) -> Void) {
        // Check if a user is logged in
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the user's path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let weekly = document["WeeklyChallengeComplete"] as? Double {
                        // Check completed the weekly lesson
                        completion(weekly >= 0.1)
                    } else {
                        print("ExperienceLevel field is missing or not in the expected format.")
                        completion(false)
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)
                }
            }
        } else {
            print("No user is logged in.")
            completion(false)
        }
    }
    
    //Reach Level 10
    func achievementLevelTenCompletion(completion: @escaping (Bool) -> Void) {
        // Check if a user is logged in
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the users path
            userDocRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    completion(false)
                    return
                }
                
                if let document = document, document.exists {
                    // ExperienceLevel field
                    if let xpLevel = document["ExperienceLevel"] as? Int {
                        // Check if user reached level 10
                        completion(xpLevel >= 10)
                    } else {
                        print("ExperienceLevel field is missing or not in the expected format.")
                        completion(false)
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)
                }
            }
        } else {
            print("No user is logged in.")
            completion(false)
        }
    }
    
    //have 1000 currency at once
    func achievementCurrencyCompletion(completion: @escaping (Bool) -> Void) {
        // Check if a user is logged in
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the document at the users path
            userDocRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    completion(false)
                    return
                }
                
                if let document = document, document.exists {
                    // ExperienceLevel field
                    if let money = document["Currency"] as? Int {
                        // Check if currency is over 1000
                        completion(money >= 1000)
                    } else {
                        print("Currency field is missing or not in the expected format.")
                        completion(false)
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)
                }
            }
        } else {
            print("No user is logged in.")
            completion(false)
        }
    }
    
}
