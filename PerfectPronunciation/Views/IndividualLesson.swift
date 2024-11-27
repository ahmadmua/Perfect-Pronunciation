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
    @ObservedObject var voiceRecorderController: VoiceRecorderController
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
                        // Display the current question
                        Text(responseText)
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
                    
                    Divider()
                } // VStack
                
                Spacer()
                
                GridRow {
                    Button(action: {
                        // Record button action
                        print("Record button pressed")
                        self.showRecord.toggle()
                        self.isPopupPresented.toggle()
                    }) {
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    } // Button
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $isPopupPresented) {
                        VoiceRecorder(
                            voiceRecorderController: VoiceRecorderController(
                                audioController: AudioController(),
                                audioAPIController: AudioAPIController(),
                                audioPlaybackController: AudioPlayBackController()
                            ),
                            testText: responseText,
                            lessonType: lessonType,
                            isPopupPresented: $isPopupPresented
                        ).environmentObject(voiceRecorderController)
                    }
                    
                    Button(action: {
                        // Continue button action
                        print("Continue button pressed")
                        counter += 1
                        
                        if counter >= responseArray.count {
                            // If all questions are completed
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
                            // Update `responseText` for the next question dynamically
                            if counter < responseArray.count {
                                responseText = responseArray[responseArray.count - 1 - counter]
                                print("Next question: \(responseText)")
                                Task {
                                    await voiceRecorderController.submitTextToSpeechAI(testText: responseText)
                                }
                            } else {
                                print("Error: Counter exceeds the bounds of responseArray. Counter: \(counter), Array Count: \(responseArray.count)")
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    } // Button
                    .alert("Congrats, You just earned XP and currency!", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {
                            currModel.updateUserCurrency()
                            xpModel.updateUserExperience()
                        }
                    }
                    .navigationDestination(isPresented: $showNext) {
                        IndividualLesson(
                            voiceRecorderController: VoiceRecorderController(
                                audioController: AudioController(),
                                audioAPIController: AudioAPIController(),
                                audioPlaybackController: AudioPlayBackController()
                            ),
                            lessonName: $lessonName,
                            responseText: $responseText,
                            responseArray: $responseArray
                        ).navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $showLesson) {
                        Details()
                            .navigationBarBackButtonHidden(true)
                    }
                    .foregroundStyle(Color.green)
                    .buttonStyle(.borderless)
                } // GridRow
            } // Grid
            .background(Color("Background"))
        } // ZStack
        .background(Color("Background"))
        .onAppear {
            // On initial load, setup the first question dynamically
            if counter == 0 {
                if !responseArray.isEmpty {
                    responseText = responseArray[responseArray.count - 1 - counter]
                    print("First question loaded: \(responseText)")
                    
                    Task {
                        // Trigger text-to-speech processing for the first question
                        await voiceRecorderController.submitTextToSpeechAI(testText: responseText)
                        // Mark the first question as loaded to ensure playback
                        isFirstQuestionLoaded = true
                    }
                } else {
                    print("Error: responseArray is empty.")
                }
            }

            openAIService.fetchAPIKey()
            
            // Find the user's difficulty
            model.findUserDifficulty {
                print("User difficulty: \(model.difficulty!)")
                UserDefaults.standard.synchronize()
            }

            self.showNext = false
        }
        .onChange(of: isFirstQuestionLoaded) { loaded in
            if loaded {
                // Play the first question's audio after it has been processed
                print("Playing audio for the first question.")
                Task {
                    await voiceRecorderController.audioPlaybackController.startPlayback()
                }
            }
        }
    }
}
