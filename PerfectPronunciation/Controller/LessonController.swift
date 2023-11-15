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
    @Published var difficulty: String?
    @Published var totQuestions: Int = 0
    
    func findUserDifficulty(completion: @escaping () -> Void){
        //get reference to database
        let db = Firestore.firestore()
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
                if let value = document["Question"] as? String {
                    print("\(value)")
                    self.question = value
                }else{
                    print("Document exists,")
                    self.question = nil
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

}
