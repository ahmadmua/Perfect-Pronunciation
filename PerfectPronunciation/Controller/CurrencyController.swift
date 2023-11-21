//
//  CurrencyController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-11-20.
//

import Foundation
import Firebase

class CurrencyController : ObservableObject{
    
    @Published var userCurr: Int = 0
    @Published var canUserPurchase: Bool = false
    @Published var userDidPurchase: Bool = false
    @Published var neededToPurchase: Int = 0
    var model = LessonController()
    
    func getUserCurrency(/*completion: @escaping () -> Void*/){
        //get reference to database
//        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Currency"] as? Int {
                        print("CURRENCY CONTROLLER : \(value)")
                        
                        //converting to proper difficutly
                        self.userCurr = value
                        
                        
                    }else{
                        print("Document exists,")
                        self.userCurr = 0
                    }
                }else{
                    print("Document does not exist")
                    self.userCurr = 0
                }
                
//                completion()
            }
            
        }
        
    }
    
    func updateUserCurrency(){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)


            //will update user currency in firebase by a set amount 
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Currency"] as? Int {
                        print("CURRENCY CONTROLLER UPDATE : \(value)")
                        
                        let updateData = ["Currency": value + 100]
                        
                        // Update the specific field in the user's document
                        userDocRef.updateData(updateData) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document updated successfully")
                            }
                        }
                        
                        
                        //FOR LATER - will make users mroe money depending on difficulty
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
                        
                        
                    }else{
                        print("Document exists,")
                        
                    }
                }else{
                    print("Document does not exist")
                    
                }
                
//                completion()
            }
            
            

            
            
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
        }
        
    }
    
    func subUserCurrency(cost : Int){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)


            //will update user currency in firebase by a set amount
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Currency"] as? Int {
                        
                        //TODO check if the user can afford what they buy
                        
                        //if they can afford it
                        //allow the purchase of the item
                        print("CURRENCY SUBTRACTION CONTROLLER UPDATE : \(value)")
                        if(value >= cost){
                            
                            let updateData = ["Currency": value - cost]
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(updateData) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document updated successfully")
                                }
                            }
                            self.userDidPurchase = true
                        }else{
                            //else - they cannot
                            //send an alert saying they are too broke
                            self.canUserPurchase = true
                            self.neededToPurchase = cost - value
                        }
                        
                        
                        
                        
                    }else{
                        print("Document exists,")
                        
                    }
                }else{
                    print("Document does not exist")
                    
                }
                
//                completion()
            }
            
            

            
            
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
        }
        
    }
    
}
