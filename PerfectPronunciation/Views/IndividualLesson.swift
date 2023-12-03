//
//  IndividualLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct IndividualLesson: View {
    //    @Binding var msgTaken: String
    @ObservedObject var model = LessonController()
    
    @State private var selection: Int? = nil
    @State private var showRecord = false
    @State private var showNext = false
    @State private var showLesson = false
    
    @State private var isPopupPresented = false
    
//    @State private var counter : Int = 0
    
    @Binding var lessonName : String
    
    @AppStorage("counter") var counter: Int = 0
    
    

    var body: some View {
        
        
//        NavigationStack{
            ZStack{
                
//                NavigationLink(destination: VoiceRecorder(), tag: 1, selection: self.$selection){}
                
                Color("background")
            Grid{
                
                Spacer()
                VStack{
                    GridRow{
                        
                        Text(model.question ?? "Could not get the question")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
                    GridRow{
                        Text("User Pronunciation")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 40)
                    }
                    
                    Divider()
                    
                    GridRow{
                        Text("Grade")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.all, 40)
                    }
                    
                }
                Spacer()
                GridRow{
                    
                    Button(action: {
                        //nav to the next word
                        print("record btn press")
//                        self.selection = 1
                        //                            self.selection = 1
                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
                    }){
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $isPopupPresented) {
                        VoiceRecorder(audioRecorder: AudioController() , audioPlayer: AudioPlayBackController(), testText: "")
                    }
//                    .navigationDestination(isPresented: $showRecord){
//                        VoiceRecorder()
////                            .navigationBarBackButtonHidden(true)
//                    }
                    
                    Button(action: {
                        print("Continue btn press")
                        
                        print("Numo q's \(model.totQuestions)")
                        print("QUESTION \(model.question ?? "WHY NO WORK")")
//                                                    self.selection = 1
                        counter+=1
                        
                        if counter >= model.totQuestions{
                            counter = 0
                            self.showLesson.toggle()
                        }else{
                            self.showNext.toggle()
                        }
                        
                        
                        
                        
                    }){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $showNext){
                        IndividualLesson(lessonName: $lessonName)
//                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson){
                        LessonsPage()
                            .navigationBarBackButtonHidden(true)
                    }
                    .foregroundStyle(Color.green)
                    .buttonStyle(.borderless)
                    
                }//grid row
            }//grid
            .background(Color("Background"))
            
                
        }//nanstack
        .background(Color("Background"))
        .onAppear{
             
            self.showNext = false
            
            model.getNumberOfQuestion(lesson: lessonName, difficulty: "Easy")
            
            
//            nextQuestion()
//            counter = 0
            
            
            model.getQuestion(lesson: lessonName, difficulty: "Easy", question: "Question\(counter)")
            
        }
//        .onDisappear{
//            counter+=1
//        }
        
        
       
        
    }
    
//    func nextQuestion(){
//        counter += 1
//    }
        
//    }//view
    
    

}//view

//#Preview {
//    IndividualLesson(msgTaken: <#Binding<String>#>)
//}
