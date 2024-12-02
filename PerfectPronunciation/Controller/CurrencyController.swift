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
    @Published var timeIncreasePurchase: Bool = false
    //lvl boost
    @Published var userLevel: Int = 0
    @Published var userDidPurchaseLevel: Bool = false
    //xmas lesson
    @Published var xMasLessonPurchase: Bool = false
    @Published var userDidPurchaseXMas: Bool = false
    
    var model = LessonController()
    
    init() {
            getUserCurrency()
        }
    
    func getUserCurrency(){
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
    
    func updateUserCurrency(difficulty: String){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)


            //will update user currency in firebase by a set amount 
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Currency"] as? Int {
                        print("CURRENCY CONTROLLER UPDATE : \(value)")
                        
                        //Currency based on difficulty
                        let baseCurr = 100
                        var currGain = baseCurr
                        
                        switch difficulty {
                        case "Easy":
                            currGain = baseCurr
                        case "Intermediate":
                            currGain = baseCurr * 2
                        case "Advanced":
                            currGain = baseCurr * 3
                        default:
                            print("Unknown difficulty level. Using base experience.")
                        }
                        
                        let updateData = ["Currency": value + currGain]
                        
                        // Update the specific field in the user's document
                        userDocRef.updateData(updateData) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document updated successfully")
                            }
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
    
    func subUserCurrency(cost : Int, item: String){
        
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
                            
                            
                            self.buyItem(storeItem: item)
                            
                            if (item == "TimeIncrease"){
                                self.userDidPurchase = true
                            } else if (item == "LevelBoost"){
                                self.userDidPurchaseLevel = true
                            }else if (item == "ChristmasLesson"){
                                self.userDidPurchaseXMas = true
                            }
                            
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
    
    func buyItem(storeItem: String){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access the "Items" from UserData in firebase
                    if var items = document.data()?["Items"] as? [String: Bool] {
                        
                        if let item = items[storeItem] {
                            print("STORE UPDATE CONTROLLER UPDATE : \(item)")
                            
                            items[storeItem] = true
                            
//                            if(item.description == "false"){
//                                self.timeIncreasePurchase = true   
//                            }
                            
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(["Items" : items]) { error in
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
    
    func checkBuyTime(){
        
        
        //Firestore reference
        let firestore = Firestore.firestore()

        // authenticated user
        if let currentUserID = Auth.auth().currentUser?.uid {
            let userDataRef = firestore.collection("UserData").document(currentUserID)
            

            // Read UserData document
            userDataRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    // Access "Achievements" from firebase
                    if let items = document.data()?["Items"] as? [String: Bool] {
                        
                        print("\(items)")
                        // Access individual achievements
                        //achievement 1
                        if let timeIncrease = items["TimeIncrease"] {
                            
                            // Use the achievement data as needed
                            print("Item : \(timeIncrease)")
                            print("\(timeIncrease.description)")
                            
                            DispatchQueue.main.async{
                                if(timeIncrease.description == "false"){
                                    UserDefaults.standard.set(false, forKey: "TimeIncreaseAvailable")
                                    self.timeIncreasePurchase = false
                                    print("TIME INCREASE FALSE : \(timeIncrease.description)")
                                    self.objectWillChange.send()
                                    
                                }else if(timeIncrease.description == "true"){
                                    self.timeIncreasePurchase = true
                                    UserDefaults.standard.set(true, forKey: "TimeIncreaseAvailable")
                                    print("TIME INCREASE TRUE : \(timeIncrease.description)")
                                    self.objectWillChange.send()
                                }
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
    
    func checkBuyChristmas(){
        
        
        //Firestore reference
        let firestore = Firestore.firestore()

        // authenticated user
        if let currentUserID = Auth.auth().currentUser?.uid {
            let userDataRef = firestore.collection("UserData").document(currentUserID)
            

            // Read UserData document
            userDataRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    // Access "Achievements" from firebase
                    if let items = document.data()?["Items"] as? [String: Bool] {
                        
                        print("\(items)")
                        if let xMasLesson = items["ChristmasLesson"] {
                            
                            // Use the achievement data as needed
                            print("Item : \(xMasLesson)")
                            print("\(xMasLesson.description)")
                            
                            DispatchQueue.main.async{
                                if(xMasLesson.description == "false"){
                                    UserDefaults.standard.set(false, forKey: "xMasLessonAvailable")
                                    self.xMasLessonPurchase = false
                                    print("XMAS FALSE : \(xMasLesson.description)")
                                    self.objectWillChange.send()
                                    
                                }else if(xMasLesson.description == "true"){
                                    self.xMasLessonPurchase = true
                                    UserDefaults.standard.set(true, forKey: "xMasLessonAvailable")
                                    print("XMAS TRUE : \(xMasLesson.description)")
                                    self.objectWillChange.send()
                                }
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
    
    func userBuyLevel(){
        guard let user = Auth.auth().currentUser else { return }
        let userID = user.uid
        let userDocRef = Firestore.firestore().collection("UserData").document(userID)

        userDocRef.getDocument { document, error in
            if let document = document, document.exists,
               let currentLevel = document["ExperienceLevel"] as? Int {

                    let newLevel = currentLevel + 1

                    // Update both XP and level in Firebase
                    userDocRef.updateData([
                        "ExperienceLevel": newLevel
                    ]) { error in
                        if let error = error {
                            print("Error updating level: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                self.userLevel = newLevel
                            }
                        }
                    }
                
            } else {
                print("Document does not exist or is missing fields")
            }
        }
    }
    
    func updateItemUse(itemUsed: String){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access the "Achievements" from UserData in firebase
                    if var items = document.data()?["Items"] as? [String: Bool] {
                        
                        if let item = items[itemUsed] {
                            print("STORE UPDATE CONTROLLER UPDATE : \(item)")
                            
                            items[itemUsed] = false
                            
//                            if(item.description == "false"){
//                                self.timeIncreasePurchase = true
//                            }
                            
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(["Items" : items]) { error in
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
    
}
