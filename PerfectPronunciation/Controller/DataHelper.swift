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
    
    func fetchAndAddDayAndTimestampToAssessment(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            completion(false)
            return
        }

        let userID = user.uid
        let userDocRef = Firestore.firestore().collection("UserData").document(userID)
        let lessonDataRef = userDocRef.collection("LessonData")

        lessonDataRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error retrieving assessment data: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let snapshot = querySnapshot else {
                print("No documents found.")
                completion(false)
                return
            }

            for document in snapshot.documents {
                // Check if DayOfWeek and Timestamp already exist
                if document["DayOfWeek"] == nil && document["Timestamp"] == nil {
                    if let assessment = document["assessment"] as? [String: Any],
                       let nBest = assessment["NBest"] as? [[String: Any]],
                       let _ = nBest.first?["AccuracyScore"] as? Float,
                       let displayText = nBest.first?["Display"] as? String {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E" // Short day format, like "Mon"
                        let currentDayOfWeek = dateFormatter.string(from: Date())
                        
          
                        let updatedData: [String: Any] = [
                            "ID" : UUID().uuidString,
                            "DayOfWeek": currentDayOfWeek,
                            "Timestamp": FieldValue.serverTimestamp() // Add current timestamp
                        ]
                        
                        // Update the document with DayOfWeek and Timestamp
                        lessonDataRef.document(document.documentID).updateData(updatedData) { error in
                            if let error = error {
                                print("Error updating document with DayOfWeek and Timestamp: \(error)")
                                completion(false)
                            } else {
                                print("Document updated successfully with DayOfWeek and Timestamp.")
                                completion(true)
                            }
                        }
                    } else {
                        print("Error parsing document structure.")
                        completion(false)
                    }
                } else {
                    print("Document already has DayOfWeek or Timestamp. Skipping update.")
                    completion(true)
                }
            }
        }
    }
    

    func uploadUserLessonData(data: PronunciationAssessmentResult) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            
            // Convert PronunciationAssessmentResult to dictionary
            if let lessonData = data.toDictionary() {
                // Add the PronunciationAssessmentResult to the "LessonData" subcollection
                Firestore.firestore().collection("UserData").document(userID).collection("LessonData")
                    .addDocument(data: lessonData) { error in
                        if let error = error {
                            print("Error adding pronunciation test data: \(error.localizedDescription)")
                        } else {
                            print("Pronunciation test data successfully added with a unique ID.")
                        }
                    }

            } else {
                print("Failed to convert PronunciationAssessmentResult to dictionary.")
            }
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated.")
        }
    }

    
    func getItemsForDayOfWeek(dayOfWeek: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items
            
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
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            // Create a query to filter documents where "dayofweek" is "Mon"
            let mondayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: weekDay)

            mondayQuery.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    var totalAccuracy: Float = 0
                    var documentCount: Float = 0

                    for document in querySnapshot!.documents {
                        if let assessment = document["assessment"] as? [String: Any],
                           let nBest = assessment["NBest"] as? [[String: Any]],
                           let accuracy = nBest.first?["AccuracyScore"] as? Float {
                            totalAccuracy += accuracy
                            documentCount += 1
                        } else {
                            //print("Document \(document.documentID) exists for Monday, but 'accuracy' field is missing or not a float.")
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
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

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
                            if let assessment = document["assessment"] as? [String: Any],
                               let nBest = assessment["NBest"] as? [[String: Any]],
                               let accuracy = nBest.first?["AccuracyScore"] as? Float {
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
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

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
                            if let assessment = document["assessment"] as? [String: Any],
                               let nBest = assessment["NBest"] as? [[String: Any]],
                               let accuracyScore = nBest.first?["AccuracyScore"] as? Float {
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
                let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

                //delete contents of word list
                self.wordList = []
                
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
                                    //TODO: TEST THIS TO SEE IF IT IS PULLING EVERY WORD
                                    if accuracy < 100.0{
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
            
            // Read the docs at a specific path
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
    
    func findUserDifficulty(completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let value = document["Difficulty"] as? String {
                        completion(value)
                    } else {
                        print("Document exists, but Difficulty field not found.")
                        completion(nil)
                    }
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
    
    func getAccuracy(atIndex index: Int, completion: @escaping (Float?) -> Void) {
          if let user = Auth.auth().currentUser {
              let userID = user.uid
              let userDocRef = Firestore.firestore().collection("UserData").document(userID)
              let itemsCollectionRef = userDocRef.collection("LessonData")

              itemsCollectionRef.getDocuments { (querySnapshot, error) in
                  if let error = error {
                      print("Error getting documents: \(error.localizedDescription)")
                      completion(nil)
                  } else {
                      let documentCount = querySnapshot?.documents.count ?? 0

                      guard documentCount > 0 else {
                          print("No documents found.")
                          completion(nil)
                          return
                      }

                      let validIndex = max(0, min(index, documentCount - 1))
                      let selectedDocument = querySnapshot!.documents[validIndex]

                      if let assessment = selectedDocument["assessment"] as? [String: Any],
                         let nBest = assessment["NBest"] as? [[String: Any]],
                         let accuracyScore = nBest.first?["AccuracyScore"] as? Float {
                          completion(accuracyScore)
                      } else {
                          print("Selected document does not have 'AccuracyScore' or the structure is not correct.")
                          completion(nil)
                      }
                  }
              }
          }
      }

    
    func getMostRecentFourAccuracies(completion: @escaping ([Float]?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            itemsCollectionRef.limit(to: 4).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let accuracies: [Float] = querySnapshot?.documents.compactMap { document in
                        if let assessment = document["assessment"] as? [String: Any],
                           let nBest = assessment["NBest"] as? [[String: Any]],
                           let accuracyScore = nBest.first?["AccuracyScore"] as? Float {
                            return accuracyScore
                        } else {
                            print("Invalid structure or 'AccuracyScore' field in document.")
                            return nil
                        }
                    } ?? []

                    if !accuracies.isEmpty {
                        // Call the completion handler with the most recent accuracies
                        completion(accuracies)
                    } else {
                        print("No valid accuracies found in the documents.")
                        completion(nil)
                    }
                }
            }
        } else {
            print("No user is currently authenticated.")
            completion(nil)
        }
    }




    // Function to get accuracy at a specific index from the most recent 4 accuracies
    func getAccuracyAtIndex(index: Int, completion: @escaping (Float?) -> Void) {
        getMostRecentFourAccuracies { accuracies in
            guard let accuracies = accuracies, index >= 0 && index < accuracies.count else {
                completion(nil)
                return
            }

            let accuracyAtIndex = accuracies[index]
            completion(accuracyAtIndex)
        }
    }

    func getMostRecentFourNames(completion: @escaping ([String]?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            itemsCollectionRef.order(by: "Timestamp", descending: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let names: [String] = querySnapshot?.documents.compactMap { document in
                        guard let name = document["Name"] as? String else {
                            print("Invalid 'Name' field in document.")
                            return nil
                        }
                        return name
                    } ?? []

                    if !names.isEmpty {
                        // Call the completion handler with the most recent 4 names
                        completion(names)
                    } else {
                        print("No valid names found in the most recent 4 documents.")
                        completion(nil)
                    }
                }
            }
        }
    }


    // Function to get name at a specific index from the most recent 4 names
    func getNameAtIndex(index: Int, completion: @escaping (String?) -> Void) {
        getMostRecentFourNames { names in
            guard let names = names, index >= 0 && index < names.count else {
                completion(nil)
                return
            }

            let nameAtIndex = names[index]
            completion(nameAtIndex)
        }
    }
    
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap { $0 as? [String: Any] }
    }
}


