//
//  LessonController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-11-07.
//

import Foundation
import Firebase

class LessonController : ObservableObject{
    
    @Published var list = [Lesson]()
    @Published var question: String?
    @Published var answer: String?
    @Published var difficulty: String?
    @Published var totQuestions: Int = 0
    
    func findUserDifficulty(completion: @escaping () -> Void){
        //get reference to database
//        let db = Firestore.firestore()
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
                            self.difficulty = "Easy"
                        }else if(value == "Intermediate"){
                            self.difficulty = "Normal"
                        }else if(value == "Advanced"){
                            self.difficulty = "Hard"
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
    
    func getLesson(){
        //get reference to database
        let db = Firestore.firestore()
        
        //read the docs at a specific path
        db.collection("Lessons").getDocuments{ snapshot, error in
            
            //check for errors
            if error == nil{
                //no errors
                
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async{
                        
                        // get all documents and create Lessons
                        self.list = snapshot.documents.map { d in
//                            return Lesson(id: d.documentID,
//                                          answer: d["answer"] as? String ?? "",
//                                          question: d["question"] as? String ?? "")
                            return Lesson(id: d.documentID)
                        }
                    }
                }
            }else{
                //error handling
            }
            
        }
    }
    
    func getQuestion(lesson: String, difficulty: String, question: String){
        //get reference to database
        let db = Firestore.firestore()
        
        //read the docs at a specific path
        db.collection("Lessons").document(lesson).collection(difficulty).document(question).getDocument { document, error in
            if let document = document, document.exists{
                //set question text value
                if let value = document["Question"] as? String {
                    print("\(value)")
                    self.question = value
                }else{
                    print("Document exists,")
                    self.question = nil
                }
                //set answer text value
                if let value = document["Answer"] as? String {
                    print("\(value)")
                    self.answer = value
                }else{
                    print("Document exists,")
                    self.answer = nil
                }
            }else{
                print("Document does not exist")
                self.question = nil
            }
        }
    }
        
        func getAnswer(lesson: String, difficulty: String, question: String){
            //get reference to database
            let db = Firestore.firestore()
            
            //read the docs at a specific path
            db.collection("Lessons").document(lesson).collection(difficulty).document(question).getDocument { document, error in
                if let document = document, document.exists{
                    //set question text value
                    if let value = document["Question"] as? String {
                        print("\(value)")
                        self.question = value
                    }else{
                        print("Document exists,")
                        self.question = nil
                    }
                    //set answer text value
                    if let value = document["Answer"] as? String {
                        print("\(value)")
                        self.answer = value
                    }else{
                        print("Document exists,")
                        self.answer = nil
                    }
                }else{
                    print("Document does not exist")
                    self.question = nil
                }
            }
        
        
        
    }
    
    func getNumberOfQuestion(lesson: String, difficulty: String){
        //get reference to database
        let db = Firestore.firestore()
        
        //read the docs at a specific path
        db.collection("Lessons").document(lesson).collection(difficulty).getDocuments { document, error in
            if let error = error{
                print("Error getting documents \(error)")
            }else{
                var count = 0
                for doc in document!.documents{
                    count+=1
                    print("\(doc.documentID) => \(doc.data())")
                }
                self.totQuestions = count
                print("Count = \(count)")
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
                                        if(userLesson == "Conversation"){
                                            UserDefaults.standard.set(true, forKey: "conversationCompleted")
                                        }else if(userLesson == "Directions"){
                                            UserDefaults.standard.set(true, forKey: "directionsCompleted")
                                        }else if(userLesson == "Food1"){
                                            UserDefaults.standard.set(true, forKey: "food1Completed")
                                        }else if(userLesson == "Food2"){
                                            UserDefaults.standard.set(true, forKey: "food2Completed")
                                        }else if(userLesson == "Numbers"){
                                            UserDefaults.standard.set(true, forKey: "numbersCompleted")
                                        }
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
        }

}
