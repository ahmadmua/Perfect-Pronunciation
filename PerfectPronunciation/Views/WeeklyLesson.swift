//
//  weeklyLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-04.
//

import SwiftUI

struct WeeklyLesson: View {
    //models
    @ObservedObject var audioPlayer: AudioPlayBackController
    @ObservedObject var audioAnalysisData : AudioAPIController
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var xpModel = ExperienceController()
    @ObservedObject var voiceRecorderController  =  VoiceRecorderController.shared
    @ObservedObject var model = LessonController()
    private let openAIService = OpenAIService()
    
    //toast
    @State private var showToast = false // State for showing the toast
    @State private var toastMessage = "" // Message to display in the toast
    @ObservedObject var toastModel = ToastController()
    
    @EnvironmentObject var fireDBHelper: DataHelper
    //recording
    @State private var recordingState = RecorderState.readyToRecord
    //navigation
    @State private var showWeekly = false
    
    @State private var countUses = 0
    
    @State var showingResultAlert : Bool = false
    
    var lessonType : String = "WeeklyChallenge"
    
    //time limit timer
    @State var timeRemaining = 15
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var items: [String] = []
    @State private var responseArray : [String] = []
    
    //state for recorder
    enum RecorderState {
        case readyToRecord
        case recording
        //case readyToPlay
        case playing
    }
    
    var body: some View {
        VStack{
            //text view to act as a timer
            Text("\(timeRemaining)")
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    if (timeRemaining == 1){
                        //end recording and submit
                        recordingState = .readyToRecord
                        voiceRecorderController.stopRecording()
                        
                        // MARK: - Nick provide integration here
                        let singleString = fireDBHelper.wordList.joined()
                        
                        Task {
                            await VoiceRecorderController.shared.submitTestAudio(testText: singleString, lessonType: lessonType)
                        }


                        
                        //give currency
                        model.findUserDifficulty {
                            currModel.updateUserCurrency(difficulty: model.difficulty!)
                        }
                        
                        //return to the main screen when timer is done
                        self.showingResultAlert = true
                        self.showWeekly = true
                        
                        
                        
                        
                    }
                    
                }
                .navigationDestination(isPresented: $showWeekly){
                    WeeklyGamePage()
                        .navigationBarBackButtonHidden(true)
                }//timer text
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            Spacer()
            
            List(fireDBHelper.harderWordList, id: \.self) { item in
                Text(item)
            }
            .onAppear{
                
                fireDBHelper.getHardWords() { (documents, error) in
                    if documents != nil {
                        let items = fireDBHelper.harderWordList
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
            
            Spacer()
            
            HStack{
                ZStack {
                    //recording buttons (all recording related code was adapted from jordan)
                    HStack(spacing: 40) {
                        
                        if recordingState != .recording {
                            Button(action: {
                                
                                voiceRecorderController.userAudioFileURL = URL(string: " ")
                                
                                voiceRecorderController.STTresult = ""
                                recordingState = RecorderState.readyToRecord
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                            }
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }//x button
                        
                        Button(action: {
                            switch recordingState {
                            case .readyToRecord:
                                do {
                                    try voiceRecorderController.startRecording()
                                    recordingState = .recording
                                    
                                } catch {
                                    print("An error occurred while starting the recording: \(error)")
                                }
                            case .recording:
//                                voiceRecorderController.stopRecording()
                                
                                recordingState = .playing
                            
                            //case .readyToPlay:
                                
                            //MARK: CHANGED NICKS CODE HERE REMEBER TO CHANGE BACK
                            case .playing:
                                audioPlayer.fileURL = voiceRecorderController.userAudioFileURL
                                audioPlayer.startPlayback()
                                recordingState = .readyToRecord
                            }
                        }) {
                            Image(systemName: getButtonImageName())
                                .font(.system(size: 75))
                                .foregroundColor(recordingState == .playing ? .blue : .yellow)
                        }
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        
                        
                        
                        Button(action: {
                            //nav to the next word
                            print("extra time")
                            
                                self.countUses += 1
                            
                            
                            //gray out if user does not have item
                            
                            // if user has item, allow them to add time (ONLY ONCE PER WEEK)
                            timeRemaining += 5
                            currModel.updateItemUse(itemUsed: "TimeIncrease")

                            
                        }){
                            Image(systemName: "clock.arrow.2.circlepath")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .buttonStyle(.borderless)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        //disable button when user doesn't have the item
                        .disabled(countUses == 1)
                        
                    }
                    
                }
                
            }//record and extra time button HSTACK
            
            .onAppear {//request permission and check for item
                
                currModel.checkBuyTime()
                
                DispatchQueue.main.async{
                
                print("PURCHASED : \(currModel.timeIncreasePurchase)")
                    
                    print(UserDefaults.standard.bool(forKey: "TimeIncreaseAvailable"))
                
                    if(UserDefaults.standard.bool(forKey: "TimeIncreaseAvailable") == false){
                        self.countUses = 1
                        
                    }else{
                        self.countUses = 0
                    }
                
                print("COUNT USES : \(self.countUses)")
                
            }            
                        
            }//on appear


        }//vstack
        .alert("+Currency \n\n You completed the weekly game! Please come back or hit the refresh button shortly to receive your results on the leaderboard!", isPresented: $showingResultAlert) {
            
            Button("OK", role: .cancel) {
                
            }
            
        }//alert
        

    }
    
    func getButtonImageName() -> String {
        switch recordingState {
        case .readyToRecord:
            return "play.circle.fill"
        case .recording:
            return "stop.circle.fill"
        case .playing:
            return "pause.circle.fill"
//        case .readyToPlay:
//            return "play.circle.fill"
        }
    }
    

}

//#Preview {
//    weeklyLesson()
//}
