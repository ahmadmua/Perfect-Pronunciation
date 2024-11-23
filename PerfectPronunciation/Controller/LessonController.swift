//
//  LessonController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-11-07.
//

import Foundation
import Firebase
import Combine

class LessonController : ObservableObject{
    
    @Published var difficulty: String?
    @Published var openAiResponseText: String?
    private var cancellable: AnyCancellable?

    
    func findUserDifficulty(completion: @escaping () -> Void){
        //get reference to database
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            
            //read the docs at a specific path
            userDocRef.getDocument { document, error in
                if let document = document, document.exists{
                    if let value = document["Difficulty"] as? String {
                        print("LESSON CONTROLLER : \(value)")
                        
                        //converting to proper difficutly
                        if(value == "Beginner"){
                            self.difficulty = "Beginner"
                        }else if(value == "Intermediate"){
                            self.difficulty = "Intermediate"
                        }else if(value == "Advanced"){
                            self.difficulty = "Advanced"
                        }
                        
                        
                    }else{
                        print("Document exists,")
                        self.difficulty = nil
                    }
                }else{
                    print("Document does not exist")
                    self.difficulty = nil
                }
                
                completion()
            }
            
        }
        
    }
    
    
    func updateLessonCompletion(userLesson: String){
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                let userDocRef = Firestore.firestore().collection("UserData").document(userID)


                userDocRef.getDocument { document, error in
                    if let document = document, document.exists {
                        // Access the "LessonsCompleted" field from UserData in Firebase
                        if var lessons = document.data()?["LessonsCompleted"] as? [String: Bool] {


                            if let currentLesson = lessons[userLesson] {
                                print("LESSONS CONTROLLER UPDATE: \(currentLesson)")

                                lessons[userLesson] = true

                                userDocRef.updateData(["LessonsCompleted": lessons]) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        print("Document updated successfully")
                                        
                                        //update user defaults
//                                        if(userLesson == "Conversation"){
//                                            UserDefaults.standard.set(true, forKey: "conversationCompleted")
//                                        }else if(userLesson == "Directions"){
//                                            UserDefaults.standard.set(true, forKey: "directionsCompleted")
//                                        }else if(userLesson == "Food1"){
//                                            UserDefaults.standard.set(true, forKey: "food1Completed")
//                                        }else if(userLesson == "Food2"){
//                                            UserDefaults.standard.set(true, forKey: "food2Completed")
//                                        }else if(userLesson == "Numbers"){
//                                            UserDefaults.standard.set(true, forKey: "numbersCompleted")
//                                        }
                                    }
                                }
                            }
                        } else {
                            print("LessonsCompleted field does not exist in the document.")
                        }
                    } else {
                        print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                // Handle the case where the user is not authenticated
                print("User is not authenticated")
            }
        }//func
    
    func updateLessonQuestionData(userLesson: String, userDifficulty: String, lessonQuestionsList: [String]) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)

            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let lessonQuestions = document.data()?["LessonQuestions"] as? [String: Any] {
                        if var lessonData = lessonQuestions[userLesson] as? [String: Any] {
                            // Update "Difficulty" and "Questions" fields
                            lessonData["Difficulty"] = userDifficulty
                            lessonData["Questions"] = lessonQuestionsList

                            // Update the nested fields in Firestore
                            userDocRef.updateData(["LessonQuestions.\(userLesson)": lessonData]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Lesson Question Document updated successfully")

                                    //I DONT THINK USER DEFAULTS NEEDS TO BE UPDATED
                                }
                            }
                        } else {
                            print("lesson field does not exist in LessonQuestions.")
                        }
                    } else {
                        print("LessonQuestions field does not exist in the document.")
                    }
                } else {
                    print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("User is not authenticated")
        }
    }

}
