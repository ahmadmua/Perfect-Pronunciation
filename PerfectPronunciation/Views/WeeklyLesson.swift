//
//  weeklyLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-04.
//

import SwiftUI

struct WeeklyLesson: View {
    @ObservedObject var audioRecorder: AudioController
    @ObservedObject var audioPlayer: AudioPlayBackController
    @ObservedObject var audioAnalysisData : AudioAPIController
    @ObservedObject var currModel = CurrencyController()
    
    @State private var isRecording = false
    @State private var recordingState = RecorderState.readyToRecord
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 50)
    
    @State private var showWeekly = false
    @State private var showRecord = false
    
//    @State private var isPopupPresented = false
    
    @State private var disableTimeBtn = false
    @State private var submitBtn = true
    
    //time limit timer
    @State var timeRemaining = 15
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //countdown timer
    @State var countdownRemaining = 3
    let timerCountdown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
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
//                        print("time remaining : 1 second")
//                        self.timeRemaining = 15
                        recordingState = .readyToRecord
                        audioRecorder.stopRecording()
                        audioRecorder.submitAudio()
                        //return to the main screen when timer is done
                        self.showWeekly = true
//                        self.submitBtn = false
//                        isPopupPresented = false
                        
                    }
                    
//                    if (timeRemaining == 0){
//                        self.showWeekly = true
//                    }
                
                }
                .navigationDestination(isPresented: $showWeekly){
                    WeeklyGamePage()
                        .navigationBarBackButtonHidden(true)
                }//timer text
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            Spacer()
            
            HStack{
                ZStack {
//                    VisualEffectView(effect: UIBlurEffect(style: .dark))
//                        .frame(width: UIScreen.main.bounds.width - 25, height: 100)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack(spacing: 40) {
                        
                        if recordingState != .recording {
                            Button(action: {
                                
                                audioRecorder.recording = Recording(fileURL: URL(string: ""), createdAt: Date())
                                
                                audioRecorder.STTresult = ""
                                recordingState = RecorderState.readyToRecord
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                            }
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        }
                        
                        Button(action: {
                            switch recordingState {
                            case .readyToRecord:
                                do {
                                    try audioRecorder.startRecording()
                                    recordingState = .recording
                                    
                                } catch {
                                    print("An error occurred while starting the recording: \(error)")
                                }
                            case .recording:
                                audioRecorder.stopRecording()
                                
                                recordingState = .playing
                            
                            //case .readyToPlay:
                                
                            
                            case .playing:
                                audioPlayer.startPlayback(audio: audioRecorder.recording.fileURL!)
                                recordingState = .readyToRecord
                            }
                        }) {
                            Image(systemName: getButtonImageName())
                                .font(.system(size: 75))
                                .foregroundColor(recordingState == .playing ? .blue : .yellow)
                        }
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        
//                        if recordingState != .recording {
//                            Button(action: {
//                                self.audioRecorder.submitAudio()
////                                self.showWeekly
////                                self.isPopupPresented = false // Add this line to dismiss the sheet
//
//                            }) {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .font(.system(size: 50))
//                                    .foregroundColor(.green)
//                            }
//                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
//                            .disabled(submitBtn)
//                        }
                        
                        
                        Button(action: {
                            //nav to the next word
                            print("extra time")
                            
                            //gray out if user does not have item
                            
                            // if user has item, allow them to add time (ONLY ONCE PER WEEK)
                            timeRemaining += 5
                            currModel.updateItemUse(itemUsed: "TimeIncrease")
                            self.disableTimeBtn = true
                            
                        }){
                            Image(systemName: "clock.arrow.2.circlepath")
                                .font(.system(size: 50, weight: .light))
                        }//btn
//                        .foregroundStyle(Color.blue)
                        .buttonStyle(.borderless)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        //disable button when user doesn't have the item
                        .disabled(!currModel.timeIncreasePurchase)
                        .disabled(disableTimeBtn)
                        
                        
                    }
                    
                    
                }
                
                
                
                
         
                
            }//record and extra time button HSTACK
            
            .onAppear {
                audioRecorder.requestAuthorization()
                currModel.checkBuyTime()
            }
        }//vstack
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
