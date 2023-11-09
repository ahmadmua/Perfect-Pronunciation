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
    @Published var totQuestions: Int = 0
    
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
