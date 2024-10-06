//
//  IndividualLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//


import SwiftUI
import Firebase
import FirebaseAuth
import Combine

struct IndividualLesson: View {
    //controller var
    @ObservedObject var model = LessonController()
    @ObservedObject var audioController : AudioController
    @ObservedObject var currModel = CurrencyController()
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
    
    @Binding var responseText: String
    @Binding var responseArray: [String]
    @State private var cancellable: AnyCancellable?
    private let openAIService = OpenAIService()
    
    
    
    var body: some View {
        
            ZStack{
                Color("Background")
            Grid{
                
                Spacer()
                
                VStack{
                    GridRow{
                       //display question
                        //Text(model.question ?? "Could not get the question")
                        Text(responseText)
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
                        VoiceRecorder(audioRecorder: AudioController() , audioPlayer: AudioPlayBackController(), audioAPIController: AudioAPIController(), testText: responseText, isPopupPresented: $isPopupPresented).environmentObject(audioController)
                    }
                    
                    Button(action: {
                        //nav to the nexet question
                        print("Continue btn press")
                    
//                        print("Numo q's \(model.totQuestions)")
//                        print("QUESTION \(model.question ?? "WHY NO WORK")")
                        //increment counter to track what question the user is on
                        counter+=1
                        
                        
                            
                        //if counter is greater than number of questions
                        if counter >= 5{//let questionCount = 0
                            //go back to the home page
                            counter = 0
                            //update the lesson as complete
                            model.updateLessonCompletion(userLesson: lessonName)
                            
                            model.findUserDifficulty{
                                model.updateLessonQuestionData(userLesson: lessonName, userDifficulty: model.difficulty!, lessonQuestionsList: responseArray)
                            }
                            
                            self.showingAlert.toggle()
                            self.showLesson.toggle()
                        
                        }else{
                            //else counter is not more than the number of questions, continue to the next question
                            self.showNext.toggle()
                        }
                        
//                        //assign the question var
//                        questionVar = model.answer!
//                        print("THIS IS THE QUESTION \(questionVar ?? "NA")")
                        
                        
                    }){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .alert("Congrats, You just earned currency!", isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) {
                                        currModel.updateUserCurrency()
                                    }
                                        }//
                    .navigationDestination(isPresented: $showNext){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson){
                        Details()
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
            for _ in responseArray{
//                print("RESPONSES : \(response)")
                responseText = responseArray[4-counter]
                
            }
            
//            let responseArray = responseText.split(separator: "~")
//            print("ARRAY : \(responseArray)")
            
            openAIService.fetchAPIKey()
            
            //find the difficulty the user has set
            model.findUserDifficulty{
                print("USER DIFICULTY!! : \(model.difficulty!)")
                
                /*
                 ------------------------------------
                 WILL PROBABLY HAVE TO RE-WRITE THIS - wont be having lessons stored like this anymore?
                 vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
                 */
                //find the number of questions for the lesson
//                model.getNumberOfQuestion(lesson: lessonName, difficulty: model.difficulty!)
//                
//                //get the current question for the page number
//                model.getQuestion(lesson: lessonName, difficulty: model.difficulty!, question: "Question\(counter)")
                
                UserDefaults.standard.synchronize()
                
            }
            
             
            self.showNext = false
         
        }
         
    }

}//view

