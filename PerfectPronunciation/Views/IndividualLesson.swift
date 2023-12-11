//
//  IndividualLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct IndividualLesson: View {
    //controller var
    @ObservedObject var model = LessonController()
    @ObservedObject var audioController : AudioController

    
    //question variable
    @State var questionVar: String?
    //navigation vars
    @State private var showRecord = false
    @State private var showNext = false
    @State private var showLesson = false
    //user difficulty
    @State private var userDifficulty: String = "Easy"
    //alrt
    @State private var showingAlert = false
    
    
    //pop up for recorder view
    @State  private var isPopupPresented = false
    //lesson name
    @Binding var lessonName : String
    //counter
    @AppStorage("counter") var counter: Int = 0
    
    
    
    
    var body: some View {
        
            ZStack{
                Color("background")
            Grid{
                
                Spacer()
                
                VStack{
                    GridRow{
                       //display question
                        Text(model.question ?? "Could not get the question")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
//                    GridRow{
//                        //displays uers response
//                        Text("User Pronunciation")
//                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
//                            .padding(.bottom, 40)
//                    }
                    
                    Divider()
                    
                   
                    
                }//vstack
                
                Spacer()
                
                GridRow{
                    
                    Button(action: {
                        //nav to the next word
                        print("record btn press")

                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
                        
                    }){
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $isPopupPresented) {
                        VoiceRecorder(audioRecorder: AudioController() , audioPlayer: AudioPlayBackController(), audioAPIController: AudioAPIController(), testText: model.answer!, isPopupPresented: $isPopupPresented).environmentObject(audioController)
                    }
                    
                    Button(action: {
                        //nav to the nexet question
                        print("Continue btn press")
                    
                        print("Numo q's \(model.totQuestions)")
                        print("QUESTION \(model.question ?? "WHY NO WORK")")
                        //increment counter to track what question the user is on
                        counter+=1
                        
                        
                            
                        //if counter is greater than number of questions
                        if counter >= model.totQuestions{
                            //go back to the home page
                            counter = 0
                            self.showLesson.toggle()
                            self.showingAlert.toggle()
                            
                            
                            
                            //update the lesson as complete
                            model.updateLessonCompletion(userLesson: lessonName)
                            
                        }else{
                            //else counter is not more than the number of questions, continue to the next question
                            self.showNext.toggle()
                        }
                        
                        //assign the question var
                        questionVar = model.answer!
                        print("THIS IS THE QUESTION \(questionVar ?? "NA")")
                        
                        
                    }){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $showNext){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson){
                        Details(showingAlert: $showingAlert)
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
            
             
            //find the difficulty the user has set
            model.findUserDifficulty{
                print("USER DIFICULTY!! : \(model.difficulty!)")
                
                //find the number of questions for the lesson
                model.getNumberOfQuestion(lesson: lessonName, difficulty: model.difficulty!)
                
                //get the current question for the page number
                model.getQuestion(lesson: lessonName, difficulty: model.difficulty!, question: "Question\(counter)")
                
                UserDefaults.standard.synchronize()
                
            }
            
             
            self.showNext = false
         
        }
         
    }
    

}//view

//#Preview {
//    IndividualLesson(msgTaken: <#Binding<String>#>)
//}
