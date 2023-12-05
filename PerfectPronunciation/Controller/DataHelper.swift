//
//  FireDBHelper.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import Foundation
import Firebase
import FirebaseAuth

class DataHelper: ObservableObject {
    
    @Published var averageAccuracy: Float = 0
    @Published var wordList = [String]()
    
    
    init(){}
    
    func updateDifficulty(selectedDifficulty: String, userData: inout UserData, selection: inout Int?){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)

            userData.setDifficulty(difficulty: (selectedDifficulty))
            
            let updatedData = ["Difficulty": selectedDifficulty]

            // Update the specific field in the user's document
            userDocRef.updateData(updatedData as [AnyHashable : Any]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document updated successfully")
                }
            }
        } else {
            // Handle the case where the user is not authenticated
        }
        
        selection = 1
    }
    
    func updateCountry(selectedCountry: String, userData: inout UserData, selection: inout Int?){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)

            userData.setCountry(country: selectedCountry)
            
            let updatedData = ["Country": userData.getCountry()]

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
        
        selection = 1
    }
    
    func updateLanguage(selectedLanguage: String, userData: inout UserData, selection: inout Int?){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)

            userData.setLanguage(language: selectedLanguage)

            let updatedData = ["Language": userData.getLanguage()]

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
        
        selection = 1
    }
    
    func addItemToUserDataCollection(itemName: String, dayOfWeek: String, accuracy: Float) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
            
            let itemData = [
                "Name": itemName,
                "DayOfWeek": dayOfWeek,
                "Accuracy": accuracy
            ] as [String : Any]
            
            // Add a new document to the "Items" subcollection
            itemsCollectionRef.addDocument(data: itemData) { error in
                if let error = error {
                    print("Error adding item to UserData subcollection: \(error)")
                } else {
                    print("Item added to UserData subcollection successfully")
                }
            }
        } else {
            // Handle the case where the user is not authenticated
        }
    }
    
    func getItemsForDayOfWeek(dayOfWeek: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
            
            // Perform a query to filter documents with "DayOfWeek" equal to "Tue"
            itemsCollectionRef.whereField("DayOfWeek", isEqualTo: dayOfWeek).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching items for \(dayOfWeek): \(error)")
                    completion(nil, error)
                } else {
                    if let documents = querySnapshot?.documents {
                        print("Items for \(dayOfWeek) retrieved successfully")
                        completion(documents, nil)
                    }
                }
            }
        } else {
            // Handle the case where the user is not authenticated
            let error = NSError(domain: "Authentication Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])
            completion(nil, error)
        }
    }
    
    func getAvgAccuracyForDayOfWeek(weekDay: String, completion: @escaping (Float) -> Void) {
        var averageAccuracy: Float = 0

        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items

            // Create a query to filter documents where "dayofweek" is "Mon"
            let mondayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: weekDay)

            mondayQuery.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    var totalAccuracy: Float = 0
                    var documentCount: Float = 0

                    for document in querySnapshot!.documents {
                        if let accuracy = document["Accuracy"] as? Float {
                            totalAccuracy += accuracy
                            documentCount += 1
                        } else {
                            print("Document \(document.documentID) exists for Monday, but 'accuracy' field is missing or not a float.")
                        }
                    }

                    averageAccuracy = documentCount > 0 ? totalAccuracy / documentCount : 0
                    //print("\(averageAccuracy)")

                    // Call the completion handler with the result
                    completion(averageAccuracy)
                }
            }
        }
    }
    
    func getAvgAccuracy(completion: @escaping (Float) -> Void) {
        var totalAccuracy: Float = 0
        var totalDocumentCount: Float = 0

        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items

            // Create an array of days
            let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            // Iterate through each day
            for day in daysOfWeek {
                let dayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: day)

                dayQuery.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                    } else {
                        var documentCount: Float = 0

                        for document in querySnapshot!.documents {
                            if let accuracy = document["Accuracy"] as? Float {
                                totalAccuracy += accuracy
                                documentCount += 1
                            } else {
                                print("Document \(document.documentID) exists for \(day), but 'accuracy' field is missing or not a float.")
                            }
                        }

                        totalDocumentCount += documentCount
                        // Note: You might want to store the results for each day for further processing or reporting.

                            // Calculate the overall average accuracy
                            let averageAccuracy = totalDocumentCount > 0 ? totalAccuracy / totalDocumentCount : 0
                            self.averageAccuracy = averageAccuracy
                            completion(averageAccuracy)
                        
                    }
                }
            }
        }
    }
    
    func getPronunciationWordCount(completion: @escaping (Int) -> Void) {
        var accuracyCount = 0

        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items

            // Create an array of days
            let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            // Iterate through each day
            for day in daysOfWeek {
                let dayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: day)

                dayQuery.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                    } else {
                        for document in querySnapshot!.documents {
                            if let _ = document["Accuracy"] as? Float {
                                accuracyCount += 1
                            } else {
                                print("Document \(document.documentID) exists for \(day), but 'accuracy' field is missing or not a float.")
                            }
                        }

                        // Note: You might want to store the results for each day for further processing or reporting.
                    }

                    // Check if this is the last day, and if so, call the completion handler
                   
                        completion(accuracyCount)
                    
                }
            }
        }
    }
    
    //function to pull all the hard words, created by nicholas, adapted from muaz code
    func getHardWords(completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                let userDocRef = Firestore.firestore().collection("UserData").document(userID)
                let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items

                // Create an array of days
                let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                // Iterate through each day
                for day in daysOfWeek {
                    let dayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: day)
                    // Perform a query to filter documents for all days of the week, since in loop
                    dayQuery.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching items for (All days of week): \(error)")
                            completion(nil, error)
                        } else {
                            //loop documents to get a single document (word)
                            for document in querySnapshot!.documents {
                                //find the accuracy of the word
                                if let accuracy = document["Accuracy"] as? Float {
                                    //if the accuracy of the word is equal or below 50
                                    if accuracy <= 50.0{
                                        //add the name of the word to the list 
                                        if let name = document["Name"] as? String {
                                            self.wordList.append(name)
                                        }
                                    }
                                } else {
                                    print("Document \(document.documentID) exists for \(day), but 'accuracy' field is missing or not a float.")
                                }
                            }
                        }
                    }
                }
                
            } else {
                // Handle the case where the user is not authenticated
                let error = NSError(domain: "Authentication Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])
                completion(nil, error)
            }
        }
    
    //update the userData to reflect the users score for the weekly challenge
    func updateWeeklyCompletion(score: Float){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access from UserData in firebase
                    if var item = document.data()?["WeeklyChallengeComplete"] as? Float {
                        

                            print("weekly complete UPDATE CONTROLLER UPDATE : \(item)")
                            
                            item = score
                            
                            // Update the specific field in the user's document
                            userDocRef.updateData(["WeeklyChallengeComplete" : item]) { error in
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
                
            }  
            
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
        }
        
    }

    
}
