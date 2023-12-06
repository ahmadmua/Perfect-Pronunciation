//
//  VoiceRecorder.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-10-27.
//

import SwiftUI
import AVFoundation



struct VoiceRecorder: View {
    @ObservedObject var audioRecorder: AudioController
    @ObservedObject var audioPlayer: AudioPlayBackController
    @ObservedObject var audioAnalysisData : AudioAPIController
    
    @ObservedObject var model = LessonController()
    
    var testText : String
    
    @State private var isRecording = false
    @State private var recordingState = RecorderState.readyToRecord
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 50)
    @State private var elapsedTime = TimeInterval(0)
    @State private var timer: Timer?
    @Binding var isPopupPresented: Bool  // Add this line to receive the state variable

    
    enum RecorderState {
        case readyToRecord
        case recording
        //case readyToPlay
        case playing
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("AppBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Recording")
                        .padding(.top, 10)
                    
                    Text(timeString(time: elapsedTime))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding(.top, 10)
                    
                    WaveformView(audioLevels: $audioLevels)
                        .frame(width: UIScreen.main.bounds.width - 25 , height: 150)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 20)
                    
                    
                    ZStack {
                        ScrollView(.vertical) {
                            
                        }
                        
                        // The VisualEffectView with the dark blur effect
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .frame(width: UIScreen.main.bounds.width - 25, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.top, 20)
                            .overlay(
                                VStack {
                                    ScrollView(.vertical) {
                                        ZStack(alignment: .topLeading) { // Align to the top and leading edges
                                            Text(testText)
                                                .lineLimit(nil)
                                                .font(.title)
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 20)
                                            
                                            Text(audioRecorder.STTresult)
                                                .lineLimit(nil)
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                            
//                                            if !audioRecorder.STTresult.isEmpty {
//                                                
//                                                
//                                            }
                                        }
                                        .padding(.top, 10)
                                    }
                                    .padding(.top, 20)
                                }
                            )
                    }
                    
                    
                    
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .frame(width: UIScreen.main.bounds.width - 25, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        HStack(spacing: 40) {
                            
                            if recordingState != .recording {
                                Button(action: {
                                    self.elapsedTime = 0.0
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
                                        startTimer()
                                    } catch {
                                        print("An error occurred while starting the recording: \(error)")
                                    }
                                case .recording:
                                    audioRecorder.stopRecording()
                                    stopTimer()
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
                            
                            if recordingState != .recording {
                                Button(action: {
                                    self.audioRecorder.submitAudio(answer: testText)
                                    self.isPopupPresented = false // Add this line to dismiss the sheet
//                                   
                                    
   
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.green)
                                }
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                }
                .padding(.top, 40)
            }
        }
        .onAppear {
            audioRecorder.requestAuthorization()
        }
    }
    
    
    
    func startTimer() {
        timer?.invalidate() // Stop any previous timer
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
            // Simulate audio level changes
            self.audioLevels = self.audioLevels.map { _ in CGFloat.random(in: 0.1...0.9) }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        audioLevels = Array(repeating: 0.5, count: 50) // Reset audio levels
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
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

struct WaveformView: View {
    @Binding var audioLevels: [CGFloat]
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(audioLevels, id: \.self) { level in
                BarView(value: level)
            }
        }
    }
}

struct BarView: View {
    var value: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.yellow)
            .frame(width: 4, height: value * 50) // Adjusted multiplier for visibility
    }
}

//struct VoiceRecorder_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceRecorder(audioRecorder: AudioController(), audioPlayer: AudioPlayBackController(), audioAnalysisData: AudioAPIController(), testText: "", isPopupPresented: Tr)
//    }
//}
