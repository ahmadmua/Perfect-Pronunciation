//
//  TestFirebaseView.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-11-07.
//

import SwiftUI
import Firebase

struct TestFirebaseView: View {
    @ObservedObject var model = LessonController()
    
    var body: some View {
        List(model.list) { item in
            Text(item.id)
//            Text(item.difficulty)
//            Text(item.language)
            
            
        }
        
//        Button(action: {
//            model.getQuestion(lesson: "Food1", difficulty: "Easy", question: "Question")
//            print(model.question ?? "")
//        }){
//            Text("Get Question")
//        }//btn
        
        Text(model.question ?? "Nothing")
        
    }
    
    init(){
        model.getLesson()
        model.getQuestion(lesson: "Food1", difficulty: "Easy", question: "Question")
    }
    

    
}

//#Preview {
//    TestFirebaseView()
//}
