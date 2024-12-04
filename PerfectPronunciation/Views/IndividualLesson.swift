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
    // Controller variables
    @ObservedObject var model = LessonController()
    @ObservedObject var voiceRecorderController = VoiceRecorderController.shared
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var xpModel = ExperienceController()
    
    // Question variable
    @State var questionVar: String?
    
    // Navigation variables
    @State private var showRecord = false
    @State private var showNext = false
    @State private var showLesson = false
    @State private var canContinue: Bool = false
    
    // Pop-up for recorder view
    @State private var isPopupPresented = false
    // Lesson name
    @Binding var lessonName: String
    // Counter
    @AppStorage("counter") var counter: Int = 0
    
    // Lesson type
    var lessonType: String = "Individual"
    
    // Response variables
    @Binding var responseText: String
    @Binding var responseArray: [String]
    
    // Track whether the first question is loaded
    @State private var isFirstQuestionLoaded = false
    
//    private let openAIService = OpenAIService()
    
    var body: some View {
        ZStack {
            Color("Background")
            Grid{
                
                
                
                VStack{
                    Spacer()
                    Text("\(counter+1)/5 Sentences")
                        .padding()
                    GridRow{
                        
                        Text("Pronounce this sentence")
                            .font(.title2)
                        
                        
                        
                        //display question
                        Text(responseText)
                            .padding()
                            .font(.title2)
                            .lineLimit(nil) // Allow the text to wrap onto multiple lines
                            .minimumScaleFactor(0.5) // Shrinks the text if it overflows the bubble
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .listRowSeparator(.hidden)
                            .overlay(alignment: .bottomLeading){
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.title)
                                    .rotationEffect(.degrees(45))
                                    .offset(x: -10, y: 10)
                                    .foregroundColor(.blue)
                            }
                        
                        Spacer()
                    }
                    .padding()
                    Divider()
                    
                    // Integrate PlaybackView component
                    GridRow {
                        if let aiAudioURL = voiceRecorderController.aiaudioFileURL {
                            PlaybackView(voiceRecorderController: voiceRecorderController, fileURL: aiAudioURL)
                                .padding(.top, 20) // Optional padding for spacing
                                .padding(.bottom, 20)
                        } else {
                            Text("AI audio is not available yet. Please try again later.")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                
                Spacer() // Second spacer
                
                GridRow {
                    Button(action: {
                        // Record button action
                        print("record btn press")
                        voiceRecorderController.stopAudio()
                        voiceRecorderController.STTresult = ""
                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
                        self.canContinue = false
                    }) {
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $isPopupPresented) {
                        VoiceRecorder(
                            voiceRecorderController: VoiceRecorderController.shared,
                            testText: responseText,
                            lessonType: lessonType,
                            isPopupPresented: $isPopupPresented
                        ).environmentObject(VoiceRecorderController.shared)
                    }
                    
                    Button(action: {
                        // Continue button action
                        print("Continue btn press")
                        
                        // Increment counter to track the question number
                        counter += 1
                        
                        //if counter is greater than number of questions
                        if counter >= 5{//let questionCount = 0
                            //finish lesson -> go to xpbarpage
                            counter = 0
                            model.updateLessonCompletion(userLesson: lessonName)
                            model.findUserDifficulty {
                                model.updateLessonQuestionData(
                                    userLesson: lessonName,
                                    userDifficulty: model.difficulty!,
                                    lessonQuestionsList: responseArray
                                )
                                
                                xpModel.getUserExperience() // Fetch user experience on view appear
                                
                                currModel.updateUserCurrency(difficulty: model.difficulty!)
                                xpModel.updateUserExperience(difficulty: model.difficulty!)
                            }
                            self.showLesson.toggle()
                        } else {
                            self.showNext.toggle()
                            if counter < responseArray.count {
                                responseText = responseArray[responseArray.count - 1 - counter]
                                print("Next question: \(responseText)")
                            } else {
                                print("Error: Counter exceeds bounds of responseArray.")
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }
                    //.disabled(!canContinue)
                    .navigationDestination(isPresented: $showNext) {
                        IndividualLesson(
                            lessonName: $lessonName,
                            responseText: $responseText,
                            responseArray: $responseArray
                        ).navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson) {
                        ExperienceBarPage(xpController: xpModel)
                            .navigationBarBackButtonHidden(true)
                    }
                    .foregroundStyle(Color.green)
                    .buttonStyle(.borderless)
                    .onAppear {
                        // Set up the view when it appears
                        self.canContinue = true
                        
//                        print("Counter: \(counter)")
                        
                        //set the published variable for the question text from the lesson list
                        for _ in responseArray{
                            //                print("RESPONSES : \(response)")
                            responseText = responseArray[4-counter]
                            
                        }
//                        openAIService.fetchAPIKey()
                        model.findUserDifficulty {
                            print("User difficulty: \(model.difficulty ?? "Unknown")")
                            UserDefaults.standard.synchronize()
                        }
                        
                        
                        self.showNext = false
                        
                        Task {
                            await voiceRecorderController.submitTextToSpeechAI(testText: responseText)
                        }
                    }
                    .onChange(of: responseText) { newValue in
                        Task {
                            await voiceRecorderController.submitTextToSpeechAI(testText: newValue)
                        }
                    }
                }
            }
            
        }//zstack
    }//body
}//view
