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
    @ObservedObject var voiceRecorderController : VoiceRecorderController
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var xpModel = ExperienceController()
    
    //navigation vars
    @State private var showRecord = false
    @State private var showNext = false
    @State private var showLesson = false
    @State private var canContinue: Bool = false
    
    //pop up for recorder view
    @State  private var isPopupPresented = false
    //lesson name
    @Binding var lessonName : String
    //counter
    @AppStorage("counter") var counter: Int = 0
    var lessonType : String = "Induvidual"
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
                        Text(responseText)
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
                    Divider()
                    
                    
                    
                }//vstack
                
                Spacer()
                
                GridRow{
                    
                    Button(action: {
                        //nav to the next word
                        print("record btn press")
                        
                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
                        self.canContinue = false
                        
                    }){
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $isPopupPresented) {
                        VoiceRecorder(voiceRecorderController: VoiceRecorderController(audioController: AudioController(), audioAPIController: AudioAPIController(), audioPlaybackController: AudioPlayBackController()), testText: responseText, lessonType: lessonType,isPopupPresented: $isPopupPresented).environmentObject(voiceRecorderController);
                    }
                    
                    Button(action: {
                        //nav to the nexet question
                        print("Continue btn press")

                        //increment counter to track what question the user is on
                        counter+=1
                        
                        
                        
                        //if counter is greater than number of questions
                        if counter >= 5{//let questionCount = 0
                            currModel.updateUserCurrency()
                            xpModel.updateUserExperience()
                            
                            //go back to the home page
                            counter = 0
                            //update the lesson as complete
                            model.updateLessonCompletion(userLesson: lessonName)
                            
                            model.findUserDifficulty{
                                model.updateLessonQuestionData(userLesson: lessonName, userDifficulty: model.difficulty!, lessonQuestionsList: responseArray)
                            }
                            
                            self.showLesson.toggle()
                            
                        }else{
                            //else counter is not more than the number of questions, continue to the next question
                            self.showNext.toggle()
                        }
                        
                        
                    }){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .disabled(canContinue)
                    
                    .navigationDestination(isPresented: $showNext){
                        IndividualLesson(voiceRecorderController: VoiceRecorderController(audioController: AudioController(), audioAPIController: AudioAPIController(), audioPlaybackController: AudioPlayBackController()), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson){
                        ExperienceBarPage(xpController: xpModel)
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
            //set so that users can't continue to the next question until they record
            self.canContinue = true

            
            for _ in responseArray{
                //                print("RESPONSES : \(response)")
                responseText = responseArray[4-counter]
                
            }
            
            openAIService.fetchAPIKey()
            
            //find the difficulty the user has set
            model.findUserDifficulty{
                print("USER DIFICULTY!! : \(model.difficulty!)")
                
                UserDefaults.standard.synchronize()
                
                
            }
            
            
            self.showNext = false
            
            Task {
                await voiceRecorderController.submitTextToSpeechAI(testText: responseText)
            }
            
        }
        
    }
    
}//view

