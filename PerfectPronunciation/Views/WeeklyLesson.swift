//
//  weeklyLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-04.
//

import SwiftUI

struct WeeklyLesson: View {
    //models
    @ObservedObject var audioRecorder: AudioController
    @ObservedObject var audioPlayer: AudioPlayBackController
    @ObservedObject var audioAnalysisData : AudioAPIController
    @ObservedObject var currModel = CurrencyController()
    
    @EnvironmentObject var fireDBHelper: DataHelper
    //recording
    @State private var isRecording = false
    @State private var recordingState = RecorderState.readyToRecord
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 50)
    //navigation
    @State private var showWeekly = false
    //button disable
    @State private var disableTimeBtn = false
    @State private var submitBtn = true
    
    //time limit timer
    @State var timeRemaining = 15
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var items: [String] = []
    
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

                        recordingState = .readyToRecord
                        audioRecorder.stopRecording()
                        audioRecorder.submitAudio()
                        
                        //return to the main screen when timer is done
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
            
            List(fireDBHelper.wordList, id: \.self) { item in
                Text(item)
            }
            .onAppear{
                fireDBHelper.getHardWords() { (documents, error) in
                    if let documents = documents {
                        let items = fireDBHelper.wordList
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
                    //recording buttons
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
                        }//x button
                        
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
                        .buttonStyle(.borderless)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        //disable button when user doesn't have the item
                        .disabled(!currModel.timeIncreasePurchase)
                        .disabled(disableTimeBtn)
                        
                        
                    }
                    
                    
                }
                
                
            }//record and extra time button HSTACK
            
            .onAppear {//request permission and check for item
                audioRecorder.requestAuthorization()
                currModel.checkBuyTime()
                
                
                        
            }//on appear
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
