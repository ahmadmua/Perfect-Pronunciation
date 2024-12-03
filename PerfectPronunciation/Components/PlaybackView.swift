//
//  PlaybackView.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2024-12-01.
//

import SwiftUI

// The PlaybackView is a SwiftUI View for handling audio playback functionality
struct PlaybackView: View {
    @ObservedObject var voiceRecorderController: VoiceRecorderController // Observing the voice recorder controller to manage playback
    private var fileURL: URL // The URL of the audio file to be played
    @State private var playbackState = PlaybackState.ready // Local state variable to track the playback state
    
    // Enum to represent the playback states
    enum PlaybackState {
        case ready // Indicates playback is ready to start
        case playing // Indicates playback is currently active
        case paused // Indicates playback is paused
    }
    
    // Custom initializer for PlaybackView to pass the voiceRecorderController and fileURL
    init(voiceRecorderController: VoiceRecorderController, fileURL: URL) {
        self.voiceRecorderController = voiceRecorderController // Initialize voiceRecorderController
        self.fileURL = fileURL // Initialize the audio file URL
    }
    
    // The body property defines the view's layout and behavior
    var body: some View {
        VStack {
            // Horizontal stack for playback buttons
            HStack(spacing: 20) { // Adds spacing between buttons
                // Button for Start/Resume/Pause actions
                Button(action: {
                    handlePlaybackButton() // Call the method to handle playback logic
                }) {
                    Image(systemName: getPlaybackButtonImage()) // Dynamically set the button icon
                        .font(.system(size: 50)) // Set the icon size
                        .foregroundColor(getPlaybackButtonColor()) // Dynamically set the button color
                }
                .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Add a circular outline around the button
                
                // Button for stopping playback (only visible during playback or pause)
                if playbackState == .playing || playbackState == .paused {
                    Button(action: {
                        stopPlayback() // Call the method to stop playback
                    }) {
                        Image(systemName: "stop.circle.fill") // Icon for the stop button
                            .font(.system(size: 50)) // Set the icon size
                            .foregroundColor(.red) // Set the button color to red
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2)) // Add a circular outline around the button
                }
            }
        }
        .padding() // Add padding around the content
        .onAppear {
            // Observe the playbackFinished notification to reset playback state
            NotificationCenter.default.addObserver(
                forName: .playbackFinished, // The notification name
                object: nil, // No specific object is observed
                queue: .main // Execute on the main thread
            ) { _ in
                playbackState = .ready // Reset playback state to ready when playback finishes
            }
        }
        .onDisappear {
            // Remove the observer to avoid memory leaks when the view disappears
            NotificationCenter.default.removeObserver(self, name: .playbackFinished, object: nil)
        }
    }
    
    // Handle actions when the playback button is pressed
    private func handlePlaybackButton() {
        switch playbackState { // Determine the current playback state
        case .ready:
            startPlayback() // Start playback when ready
        case .playing:
            pausePlayback() // Pause playback when playing
        case .paused:
            resumePlayback() // Resume playback when paused
        }
    }
    
    // Start audio playback
    private func startPlayback() {
        voiceRecorderController.playAudio(fileURL: fileURL) // Use the controller to play the audio file
        playbackState = .playing // Update the playback state to playing
    }
    
    // Pause audio playback
    private func pausePlayback() {
        voiceRecorderController.pauseAudio() // Use the controller to pause audio
        playbackState = .paused // Update the playback state to paused
    }
    
    // Resume audio playback
    private func resumePlayback() {
        voiceRecorderController.resumeAudio() // Use the controller to resume audio
        playbackState = .playing // Update the playback state to playing
    }
    
    // Stop audio playback
    private func stopPlayback() {
        voiceRecorderController.stopAudio() // Use the controller to stop audio
        playbackState = .ready // Update the playback state to ready
    }
    
    // Determine the appropriate icon for the playback button based on the state
    private func getPlaybackButtonImage() -> String {
        switch playbackState {
        case .ready:
            return "play.circle.fill" // Icon for the ready state
        case .playing:
            return "pause.circle.fill" // Icon for the playing state
        case .paused:
            return "play.circle.fill" // Icon for the paused state
        }
    }
    
    // Determine the appropriate color for the playback button based on the state
    private func getPlaybackButtonColor() -> Color {
        switch playbackState {
        case .ready:
            return .green // Green color for the ready state
        case .playing:
            return .yellow // Yellow color for the playing state
        case .paused:
            return .blue // Blue color for the paused state
        }
    }
}

// Preview for the PlaybackView
struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample URL for the preview
        PlaybackView(
            voiceRecorderController: VoiceRecorderController.shared,
            fileURL: URL(string: "https://example.com/audiofile.mp3")! // Example audio file URL
        )
    }
}
