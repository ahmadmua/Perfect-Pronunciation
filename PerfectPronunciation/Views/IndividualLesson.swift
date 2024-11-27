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
    
    // User difficulty
    @State private var userDifficulty: String = "Easy"
    
    // Alert
    @State private var showingAlert = false
    
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
    
    private let openAIService = OpenAIService()
    
    
    var body: some View {
        ZStack {
            Color("Background")
            Grid {
                Spacer()
                VStack {
                    GridRow {
                        Text(responseText)
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
                    Divider()
                }
                
                Spacer()
                
                GridRow {
                    Button(action: {
                        print("Record button pressed")
                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
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
                        print("Continue button pressed")
                        counter += 1
                        
                        if counter >= responseArray.count {
                            counter = 0
                            model.updateLessonCompletion(userLesson: lessonName)
                            model.findUserDifficulty {
                                model.updateLessonQuestionData(
                                    userLesson: lessonName,
                                    userDifficulty: model.difficulty!,
                                    lessonQuestionsList: responseArray
                                )
                            }
                            self.showingAlert.toggle()
                            self.showLesson.toggle()
                        } else {
                            if counter < responseArray.count {
                                responseText = responseArray[responseArray.count - 1 - counter]
                                print("Next question: \(responseText)")
                                Task {
                                    VoiceRecorderController.shared.clearAudioFiles() // Access directly from the singleton
                                    await VoiceRecorderController.shared.submitTextToSpeechAI(testText: responseText) // Access directly
                                    
                                    VoiceRecorderController.shared.playAudio(fileURL: self.voiceRecorderController.aiaudioFileURL) // Access directly for playback
                                }
                            } else {
                                print("Error: Counter exceeds the bounds of responseArray. Counter: \(counter), Array Count: \(responseArray.count)")
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }
                    .alert("Congrats, You just earned XP and currency!", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {
                            currModel.updateUserCurrency()
                            xpModel.updateUserExperience()
                        }
                    }
                    .navigationDestination(isPresented: $showNext) {
                        IndividualLesson(
                            lessonName: $lessonName,
                            responseText: $responseText,
                            responseArray: $responseArray
                        ).navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson) {
                        Details().navigationBarBackButtonHidden(true)
                    }
                    .foregroundStyle(Color.green)
                    .buttonStyle(.borderless)
                }
            }
            .background(Color("Background"))
        }
        .background(Color("Background"))
        .onAppear {
            if counter == 0, !responseArray.isEmpty {
                responseText = responseArray[responseArray.count - 1 - counter]
                print("First question loaded: \(responseText)")
                
                Task {
                    await voiceRecorderController.submitTextToSpeechAI(testText: responseText)
                    voiceRecorderController.playAudio(fileURL:  self.voiceRecorderController.aiaudioFileURL) // Play AI audio for the first question
                }
            }
        }
    }
}
