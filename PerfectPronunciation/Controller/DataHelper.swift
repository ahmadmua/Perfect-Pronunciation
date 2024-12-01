//
//  FireDBHelper.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class DataHelper: ObservableObject {
    
    @Published var averageAccuracy: Double = 0
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
    
//    func updateLanguage(selectedLanguage: String, userData: inout UserData, selection: inout Int?){
//
//        if let user = Auth.auth().currentUser {
//            let userID = user.uid
//            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
//
//            userData.setLanguage(language: selectedLanguage)
//
//            let updatedData = ["Language": userData.getLanguage()]
//
//            // Update the specific field in the user's document
//            userDocRef.updateData(updatedData) { error in
//                if let error = error {
//                    print("Error updating document: \(error)")
//                } else {
//                    print("Document updated successfully")
//                }
//            }
//
//        } else {
//            // Handle the case where the user is not authenticated
//        }
//
//        selection = 1
//    }
    
//    func addItemToUserDataCollection(itemName: String, dayOfWeek: String, accuracy: Float) {
//        if let user = Auth.auth().currentUser {
//            let userID = user.uid
//            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
//            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
//
//            // Check if an item with the same name already exists
//            let query = itemsCollectionRef.whereField("Name", isEqualTo: itemName)
//
//            query.getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error querying for existing item: \(error)")
//                } else if let snapshot = querySnapshot, !snapshot.isEmpty {
//                    // Item with the same name already exists
//                    print("Item with the same name already exists")
//                    // Check if the current accuracy is higher than the stored accuracy
//                    if let existingItemAccuracy = snapshot.documents.first?.data()["Accuracy"] as? Float,
//                       accuracy > existingItemAccuracy {
//                        // Update the existing item with the new accuracy
//                        let documentID = snapshot.documents.first!.documentID
//                        itemsCollectionRef.document(documentID).updateData(["Accuracy": accuracy]) { error in
//                            if let error = error {
//                                print("Error updating existing item: \(error)")
//                            } else {
//                                print("Existing item updated with higher accuracy")
//                            }
//                        }
//                    } else {
//                        print("Current accuracy is not higher than the stored accuracy. Item not updated.")
//                    }
//                } else {
//                    // Item with the same name does not exist, add the new item
//                    let itemData = [
//                        "DayOfWeek": dayOfWeek,
//                        "Timestamp": FieldValue.serverTimestamp(),
//                    ] as [String : Any]
//
//                    // Add a new document to the "Items" subcollection
//                    itemsCollectionRef.addDocument(data: itemData) { error in
//                        if let error = error {
//                            print("Error adding item to UserData subcollection: \(error)")
//                        } else {
//                            print("Item added to UserData subcollection successfully")
//                        }
//                    }
//                }
//            }
//        } else {
//            // Handle the case where the user is not authenticated
//        }
//    }
    
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
    
    func uploadUserLessonData(assessmentData: PronunciationAssessmentResult, userAudio: URL, voiceGalleryAudio: URL) {
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return
        }

        let userID = user.uid

        // Check if files exist at the given URLs
        guard FileManager.default.fileExists(atPath: userAudio.path) else {
            print("User audio file does not exist at path: \(userAudio.path)")
            return
        }

        guard FileManager.default.fileExists(atPath: voiceGalleryAudio.path) else {
            print("Voice gallery audio file does not exist at path: \(voiceGalleryAudio.path)")
            return
        }

        // Debugging the paths
        print("Local user audio file path: \(userAudio.path)")
        print("Local voice gallery audio file path: \(voiceGalleryAudio.path)")

        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://perfectpronunciation-3aeeb.appspot.com")

        // Firebase storage references
        let userAudioRef = storageRef.child("userAudio/\(userID)/\(UUID().uuidString).wav")
        let voiceGalleryAudioRef = storageRef.child("voiceGalleryAudio/\(userID)/\(UUID().uuidString).wav")

        let metadata = StorageMetadata()
        metadata.contentType = "audio/wav"

        // Upload user audio
        let userAudioUploadTask = userAudioRef.putFile(from: userAudio, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to upload user audio: \(error.localizedDescription)")
                return
            }

            print("User audio uploaded successfully.")
            userAudioRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get user audio URL: \(error.localizedDescription)")
                    return
                }

                guard let userAudioURL = url?.absoluteString else { return }
                print("User audio URL: \(userAudioURL)")

                // Upload voice gallery audio
                let voiceGalleryUploadTask = voiceGalleryAudioRef.putFile(from: voiceGalleryAudio, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Failed to upload voice gallery audio: \(error.localizedDescription)")
                        return
                    }

                    print("Voice gallery audio uploaded successfully.")
                    voiceGalleryAudioRef.downloadURL { url, error in
                        if let error = error {
                            print("Failed to get voice gallery audio URL: \(error.localizedDescription)")
                            return
                        }

                        guard let voiceGalleryAudioURL = url?.absoluteString else { return }
                        print("Voice gallery audio URL: \(voiceGalleryAudioURL)")

                        // Save the data to Firestore
                        var assessmentLessonData = assessmentData.toDictionary() ?? [:]
                        assessmentLessonData["userAudioURL"] = userAudioURL
                        assessmentLessonData["voiceGalleryAudioURL"] = voiceGalleryAudioURL

                        Firestore.firestore().collection("UserData").document(userID).collection("LessonData")
                            .addDocument(data: assessmentLessonData) { error in
                                if let error = error {
                                    print("Error adding pronunciation test data: \(error.localizedDescription)")
                                } else {
                                    print("Pronunciation test data and audio files successfully uploaded.")
                                }
                            }
                    }
                }
            }
        }
    }






    
    func getItemsForDayOfWeek(dayOfWeek: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items
            
            
            itemsCollectionRef
                .whereField("DayOfWeek", isEqualTo: dayOfWeek)
                .whereField("lessonType", isEqualTo: "Individual")
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching items for \(dayOfWeek): \(error)")
                        completion(nil, error)
                    } else {
                        if let documents = querySnapshot?.documents {
                            print("Items for \(dayOfWeek) with individual lessonType retrieved successfully")
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

    
    func getAvgAccuracyForDayOfWeek(weekDay: String, completion: @escaping (Double) -> Void) {
        var averageAccuracy: Double = 0

        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            // Create a query to filter documents where "DayOfWeek" is the provided weekDay and "lessonType" is "Individual"
            let filteredQuery = itemsCollectionRef
                .whereField("DayOfWeek", isEqualTo: weekDay)
                .whereField("lessonType", isEqualTo: "Individual")  // Add filter for lessonType

            filteredQuery.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    var totalAccuracy: Double = 0
                    var documentCount: Double = 0

                    for document in querySnapshot!.documents {
                        if let assessment = document["assessment"] as? [String: Any],
                           let nBest = assessment["NBest"] as? [[String: Any]],
                           let accuracy = nBest.first?["PronScore"] as? Double {
                            totalAccuracy += accuracy
                            documentCount += 1
                        }
                    }

                    averageAccuracy = documentCount > 0 ? totalAccuracy / documentCount : 0

                    // Call the completion handler with the result
                    completion(averageAccuracy)
                }
            }
        }
    }

    
    func getAvgAccuracy(completion: @escaping (Double) -> Void) {
        var totalAccuracy: Double = 0
        var totalDocumentCount: Double = 0

        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            // Create an array of days
            let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            // Iterate through each day
            for day in daysOfWeek {
                let dayQuery = itemsCollectionRef
                    .whereField("DayOfWeek", isEqualTo: day)
                    .whereField("lessonType", isEqualTo: "Individual")

                dayQuery.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                    } else {
                        var documentCount: Double = 0

                        for document in querySnapshot!.documents {
                            if let assessment = document["assessment"] as? [String: Any],
                               let nBest = assessment["NBest"] as? [[String: Any]],
                               let accuracy = nBest.first?["PronScore"] as? Double {
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
                    .whereField("lessonType", isEqualTo: "Individual")

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

                    }

                    
                   
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

            // Delete contents of word list
            self.wordList = []

            // Create an array of days
            let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            // Iterate through each day
            for day in daysOfWeek {
                // Perform a query to filter documents for the current day and lessonType
                let dayQuery = itemsCollectionRef
                    .whereField("DayOfWeek", isEqualTo: day)
                    .whereField("lessonType", isEqualTo: "Individual")

                dayQuery.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching items for \(day): \(error)")
                        completion(nil, error)
                    } else {
                        // Loop documents to get a single document (word)
                        for document in querySnapshot!.documents {
                            // Find the accuracy of the word
                            if let assessment = document["assessment"] as? [String: Any],
                               let nBest = assessment["NBest"] as? [[String: Any]],
                               let accuracy = nBest.first?["PronScore"] as? Double {
                                
                                // If the accuracy of the word is equal or below 100
                                if accuracy < 80.0 {
                                    // Add the name of the word to the list
                                    if let name = nBest.first?["Display"] as? String {
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
    func updateWeeklyCompletion(score: Double){
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            // Read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    // Access from UserData in firebase
                    if var item = document.data()?["WeeklyChallengeComplete"] as? Double {
                        

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
    
    func getWeeklyAccuracy(completion: @escaping (Double?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            // Assuming you have a timestamp field in your documents (e.g., "timestamp")
            itemsCollectionRef.order(by: "Timestamp", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    guard let document = querySnapshot?.documents.first else {
                        print("No documents found.")
                        completion(nil)
                        return
                    }

                    // Extracting AccuracyScore from the new structure
                    if let lessonType = document["lessonType"] as? String, lessonType == "WeeklyChallenge",
                       let assessment = document["assessment"] as? [String: Any],
                       let nBest = assessment["NBest"] as? [[String: Any]],
                       let accuracyScore = nBest.first?["PronScore"] as? Double {
                        // Call the completion handler with the accuracy score from the most recent document
                        completion(accuracyScore)
                    } else {
                        print("Selected document does not have 'AccuracyScore' or the structure is not correct.")
                        completion(nil)
                    }
                }
            }
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
    
    func getAccuracy(atIndex index: Int, completion: @escaping (Double?) -> Void) {
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
                         let accuracyScore = nBest.first?["PronScore"] as? Double {
                          completion(accuracyScore)
                      } else {
                          print("Selected document does not have 'AccuracyScore' or the structure is not correct.")
                          completion(nil)
                      }
                  }
              }
          }
      }
    
    

    
    func getMostRecentFourAccuracies(completion: @escaping ([Double]?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("LessonData") // Subcollection for items

            itemsCollectionRef.whereField("lessonType", isEqualTo: "Individual").limit(to: 4).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let accuracies: [Double] = querySnapshot?.documents.compactMap { document in
                        if let assessment = document["assessment"] as? [String: Any],
                           let nBest = assessment["NBest"] as? [[String: Any]],
                           let accuracyScore = nBest.first?["PronScore"] as? Double {
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
    func getAccuracyAtIndex(index: Int, completion: @escaping (Double?) -> Void) {
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
                        guard let name = document["Timestamp"] as? String else {
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


