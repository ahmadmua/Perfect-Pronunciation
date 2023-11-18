//
//  FireDBHelper.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import Foundation
import Firebase
import FirebaseAuth

class FireDBHelper: ObservableObject {
    
    
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
    
    func getAvgAccuracy(weekDay: String, completion: @escaping (Float) -> Void) {
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

    
}
