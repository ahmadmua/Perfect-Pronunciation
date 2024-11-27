//
//  VoiceRecorder.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-10-27.
//

import SwiftUI
import AVFoundation

struct VoiceRecorder: View {
    // Observed objects to keep track of changes in the controllers
    @ObservedObject var voiceRecorderController: VoiceRecorderController
    @ObservedObject var model = LessonController()
    
    // Variables for the test text and lesson type
    var testText: String
    var lessonType: String
    
    // State variables to manage recording state and UI updates
    @State private var recordingState = RecorderState.readyToRecord
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 50)
    @State private var elapsedTime = TimeInterval(0)
    @State private var timer: Timer?
    @Binding var isPopupPresented: Bool // Binding to control the presentation of the view
    
    // Enum to represent the different states of the recorder
    enum RecorderState {
        case readyToRecord
        case recording
        case recorded
        case playing
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image for the entire view
                Image("AppBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Display the current mode of the voice recorder (e.g., "Recording...", "Ready to Record")
                    Text(voiceRecorderController.mode.description)
                        .padding(.top, 10)
                    
                    // Display the elapsed time during recording
                    Text(timeString(time: elapsedTime))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding(.top, 10)
                    
                    // Waveform visualization of the audio levels
                    WaveformView(audioLevels: $audioLevels)
                        .frame(width: UIScreen.main.bounds.width - 25, height: 150)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 20)
                    
                    ZStack {
                        // Scroll view to allow vertical scrolling if needed
                        ScrollView(.vertical) {}
                        
                        // Blurred effect view to display the test text and transcribed text
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .frame(width: UIScreen.main.bounds.width - 25, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.top, 20)
                            .overlay(
                                VStack {
                                    // Scroll view for the text content
                                    ScrollView(.vertical) {
                                        ZStack(alignment: .topLeading) {
                                            // Display the test text in gray color
                                            Text(testText)
                                                .lineLimit(nil)
                                                .font(.title)
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 20)
                                            
                                            // Display the transcribed speech-to-text result in white color
                                            Text(voiceRecorderController.STTresult)
                                                .lineLimit(nil)
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                        }
                                        .padding(.top, 10)
                                    }
                                    .padding(.top, 20)
                                }
                            )
                    }
                    
                    // Bottom bar with dynamic content based on the recording state
                    ZStack {
                        // Blurred effect view for the bottom control bar
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .frame(width: UIScreen.main.bounds.width - 25, height: recordingState == .recorded || recordingState == .playing ? 150 : 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                // Horizontal stack to arrange buttons side by side
                                HStack(spacing: 40) {
                                    // Show discard button if recording is done or audio is playing
                                    if recordingState == .recorded || recordingState == .playing {
                                        Button(action: {
                                            // Action to discard the recorded audio
                                            voiceRecorderController.discardTestAudio(fileURL: voiceRecorderController.userAudioFileURL!)
                                            voiceRecorderController.STTresult = ""
                                            recordingState = .readyToRecord
                                        }) {
                                            // Discard button with red 'X' icon
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.red)
                                        }
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Circle border around the icon
                                    }
                                    
                                    // Main button to handle recording, stopping, playing, and pausing
                                    Button(action: {
                                        handleMainButtonAction()
                                    }) {
                                        // Icon changes based on the recording state
                                        Image(systemName: getButtonImageName())
                                            .font(.system(size: 75))
                                            .foregroundColor(recordingState == .playing ? .blue : .yellow)
                                    }
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Circle border around the icon
                                    
                                    // Show submit button if recording is done or audio is playing
                                    if recordingState == .recorded || recordingState == .playing {
                                        Button(action: {
                                            // Action to submit the recorded audio
                                            Task {
                                                await voiceRecorderController.submitTestAudio(testText: testText, lessonType: lessonType)
                                                isPopupPresented = false
                                            }
                                        }) {
                                            // Submit button with green checkmark icon
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.green)
                                        }
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Circle border around the icon
                                    }
                                }
                            )
                    }
                }
                .padding(.top, 40)
            }
        }
    }
    
    // Function to handle the main button's action based on the recording state
    private func handleMainButtonAction() {
        switch recordingState {
        case .readyToRecord:
            startRecording() // Begin recording
        case .recording:
            stopRecording() // Stop recording
        case .recorded:
            playRecordedAudio() // Play the recorded audio
        case .playing:
            stopPlayback() // Stop the audio playback
        }
    }
    
    // Function to start recording audio
    private func startRecording() {
        do {
            try voiceRecorderController.startRecording()
            recordingState = .recording
            startTimer() // Start the timer for elapsed time
        } catch {
            print("Error while starting recording: \(error)")
        }
    }
    
    // Function to stop recording audio
    private func stopRecording() {
        voiceRecorderController.stopRecording()
        stopTimer() // Stop the timer
        recordingState = .recorded
    }
    
    // Function to play the recorded audio
    private func playRecordedAudio() {
        guard let userAudioURL = voiceRecorderController.userAudioFileURL else {
            print("Error: No user audio file to play.")
            return
        }
        voiceRecorderController.playAudio(fileURL: userAudioURL)
        recordingState = .playing
    }
    
    // Function to stop audio playback
    private func stopPlayback() {
        voiceRecorderController.stopAudio()
        recordingState = .recorded
    }
    
    // Function to start the timer for recording duration and update audio levels
    func startTimer() {
        timer?.invalidate() // Stop any previous timer
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
            // Simulate audio level changes for the waveform visualization
            self.audioLevels = self.audioLevels.map { _ in CGFloat.random(in: 0.1...0.9) }
        }
    }
    
    // Function to stop the timer and reset audio levels
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        audioLevels = Array(repeating: 0.5, count: 50) // Reset audio levels
    }
    
    // Helper function to format time interval into mm:ss format
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    // Function to get the appropriate button image name based on recording state
    func getButtonImageName() -> String {
        switch recordingState {
        case .readyToRecord:
            return "record.circle" // Red record button
        case .recording:
            return "stop.circle.fill" // Stop button
        case .recorded:
            return "play.circle.fill" // Play button
        case .playing:
            return "pause.circle.fill" // Pause button
        }
    }
}

// View to display the waveform visualization
struct WaveformView: View {
    @Binding var audioLevels: [CGFloat] // Binding to the audio levels array
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            // Loop through audio levels to create individual bars
            ForEach(audioLevels, id: \.self) { level in
                BarView(value: level)
            }
        }
    }
}

// View to represent a single bar in the waveform
struct BarView: View {
    var value: CGFloat // The height value of the bar
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.yellow) // Color of the bar
            .frame(width: 4, height: value * 50) // Width and dynamic height based on audio level
    }
}


//struct VoiceRecorder_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceRecorder(audioRecorder: AudioController(), audioPlayer: AudioPlayBackController(), audioAnalysisData: AudioAPIController(), testText: "", isPopupPresented: Tr)
//    }
//}
