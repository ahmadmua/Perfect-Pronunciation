//
//  AudioPlayBackController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-12-02.
//
import Foundation
import SwiftUI
import Combine
import AVFoundation

// This class handles audio playback functionality, including playing, pausing, resuming, stopping, and seeking audio.
class AudioPlayBackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // A Combine subject that notifies subscribers when the controller's properties change.
    let objectWillChange = PassthroughSubject<AudioPlayBackController, Never>()
    
    // A boolean property that indicates whether audio is currently playing.
    @Published var isPlaying = false {
        didSet {
            // Notify subscribers whenever the `isPlaying` state changes.
            objectWillChange.send(self)
        }
    }
    
    // The AVAudioPlayer instance that handles audio playback.
    private var audioPlayer: AVAudioPlayer?
    
    // A URL property to hold the audio file's location. This is required for playback.
    var fileURL: URL? {
        didSet {
            // Log a message when the file URL is set or cleared.
            if let fileURL = fileURL {
                print("Audio file URL set to: \(fileURL.path)")
            } else {
                print("Audio file URL cleared.")
            }
        }
    }
    
    // Method to start playing the audio file from the `fileURL`.
    func startPlayback() {
        // Ensure that a valid file URL is set before attempting playback.
        guard let audio = fileURL else {
            print("Error: No audio file URL is set. Please provide a valid audio file URL before attempting to play.")
            return
        }
        
        // Check if the audio file exists at the provided URL.
        guard FileManager.default.fileExists(atPath: audio.path) else {
            print("Error: Audio file not found at path: \(audio.path)")
            return
        }
        
        // Get the shared audio session instance for playback configuration.
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            // Set the audio session category to `.playback` to allow audio to play even when the app is in the background.
            try playbackSession.setCategory(.playback, mode: .default, options: [])
            // Activate the audio session.
            try playbackSession.setActive(true)
            // Direct the audio output to the device's speaker.
            try playbackSession.overrideOutputAudioPort(.speaker)
        } catch {
            // Log an error message if configuring the audio session fails.
            print("Error: Failed to configure audio session for playback: \(error.localizedDescription)")
            return
        }
        
        do {
            // Initialize the AVAudioPlayer with the audio file URL.
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            // Set the controller as the delegate to handle playback completion events.
            audioPlayer?.delegate = self
            // Start playing the audio.
            audioPlayer?.play()
            // Update the `isPlaying` property to true.
            isPlaying = true
            print("Audio playback started successfully.")
        } catch {
            // Log an error message if initializing the audio player fails.
            print("Error: Playback failed: \(error.localizedDescription)")
        }
    }
    
    // Method to stop audio playback.
    func stopPlayback() {
        // Ensure that audio is currently playing before attempting to stop.
        guard isPlaying, let audioPlayer = audioPlayer else {
            print("Error: No audio is currently playing to stop.")
            return
        }
        
        // Stop the audio player.
        audioPlayer.stop()
        // Reset the `isPlaying` property to false.
        isPlaying = false
        print("Audio playback stopped.")
    }
    
    // Method to pause the playback of audio.
    func pausePlayback() {
        // Ensure that audio is currently playing before attempting to pause.
        guard isPlaying, let audioPlayer = audioPlayer else {
            print("Error: No audio is currently playing to pause.")
            return
        }
        
        // Pause the audio player.
        audioPlayer.pause()
        // Update the `isPlaying` property to false.
        isPlaying = false
        print("Audio playback paused.")
    }
    
    // Method to resume audio playback from where it was paused.
    func resumePlayback() {
        // Ensure that audio is loaded and not already playing.
        guard let audioPlayer = audioPlayer, !isPlaying else {
            print("Error: Either no audio is loaded or audio is already playing.")
            return
        }
        
        // Resume playback.
        audioPlayer.play()
        // Update the `isPlaying` property to true.
        isPlaying = true
        print("Audio playback resumed.")
    }
    
    // Method to get the total duration of the audio file in seconds.
    func getAudioDuration() -> TimeInterval? {
        // Ensure that an audio file is loaded.
        guard let audioPlayer = audioPlayer else {
            print("Error: No audio is loaded to get its duration.")
            return nil
        }
        // Return the total duration of the audio file.
        return audioPlayer.duration
    }
    
    // Method to get the current playback time in seconds.
    func getCurrentPlaybackTime() -> TimeInterval? {
        // Ensure that an audio file is loaded.
        guard let audioPlayer = audioPlayer else {
            print("Error: No audio is loaded to get its current playback time.")
            return nil
        }
        // Return the current playback time.
        return audioPlayer.currentTime
    }
    
    // Method to set the playback time to a specific point (seek functionality).
    func seekTo(time: TimeInterval) {
        // Ensure that an audio file is loaded.
        guard let audioPlayer = audioPlayer else {
            print("Error: No audio is loaded to seek.")
            return
        }
        
        // Ensure the specified time is within the valid range of the audio file's duration.
        guard time >= 0 && time <= audioPlayer.duration else {
            print("Error: Invalid seek time. It must be between 0 and \(audioPlayer.duration) seconds.")
            return
        }
        
        // Set the playback time to the specified point.
        audioPlayer.currentTime = time
        print("Playback seeked to \(time) seconds.")
    }
    
    // Delegate method that gets called when the audio player finishes playing an audio file.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // If playback finishes successfully, update the `isPlaying` property to false.
        if flag {
            isPlaying = false
            print("Audio playback finished successfully.")
        } else {
            print("Audio playback finished with errors.")
        }
    }
}
