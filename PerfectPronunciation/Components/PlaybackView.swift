//
//  PlaybackView.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2024-12-01.
//

import SwiftUI

struct PlaybackView: View {
    @ObservedObject var voiceRecorderController: VoiceRecorderController
    @State private var playbackState = PlaybackState.ready // Local playback state to manage button behavior
    
    enum PlaybackState {
        case ready
        case playing
        case paused
    }
    
    var body: some View {
        VStack {
            // Display playback mode description
            Text(voiceRecorderController.mode.description)
                .font(.headline)
                .padding()
            
            HStack(spacing: 20) {
                // Start/Resume/Pause button
                Button(action: {
                    handlePlaybackButton()
                }) {
                    Image(systemName: getPlaybackButtonImage())
                        .font(.system(size: 50))
                        .foregroundColor(getPlaybackButtonColor())
                }
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                
                // Stop button (only visible during playback or pause)
                if playbackState == .playing || playbackState == .paused {
                    Button(action: {
                        stopPlayback()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
            }
        }
        .padding()
        .onAppear {
            // Observe the playbackFinished notification
            NotificationCenter.default.addObserver(
                forName: .playbackFinished,
                object: nil,
                queue: .main
            ) { _ in
                playbackState = .ready // Reset the playback state to ready when playback finishes
            }
        }
        .onDisappear {
            // Remove the observer to avoid memory leaks
            NotificationCenter.default.removeObserver(self, name: .playbackFinished, object: nil)
        }
    }
    
    // Function to handle playback button actions
    private func handlePlaybackButton() {
        switch playbackState {
        case .ready:
            startPlayback()
        case .playing:
            pausePlayback()
        case .paused:
            resumePlayback()
        }
    }
    
    // Start playback
    private func startPlayback() {
        guard let aiAudioURL = voiceRecorderController.aiaudioFileURL else {
            print("Error: No AI audio file to play.")
            return
        }
        voiceRecorderController.playAudio(fileURL: aiAudioURL)
        playbackState = .playing
    }
    
    // Pause playback
    private func pausePlayback() {
        voiceRecorderController.pauseAudio()
        playbackState = .paused
    }
    
    // Resume playback
    private func resumePlayback() {
        voiceRecorderController.resumeAudio()
        playbackState = .playing
    }
    
    // Stop playback
    private func stopPlayback() {
        voiceRecorderController.stopAudio()
        playbackState = .ready
    }
    
    // Get the appropriate image for the playback button
    private func getPlaybackButtonImage() -> String {
        switch playbackState {
        case .ready:
            return "play.circle.fill"
        case .playing:
            return "pause.circle.fill"
        case .paused:
            return "play.circle.fill"
        }
    }
    
    // Get the appropriate color for the playback button
    private func getPlaybackButtonColor() -> Color {
        switch playbackState {
        case .ready:
            return .green
        case .playing:
            return .yellow
        case .paused:
            return .blue
        }
    }
}

// Preview for the PlaybackView
struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackView(voiceRecorderController: VoiceRecorderController.shared)
    }
}

