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

// This class handles the audio playback functionality.
class AudioPlayBackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // A subject that emits changes to subscribers, used here to announce when properties change.
    let objectWillChange = PassthroughSubject<AudioPlayBackController, Never>()
    
    // A boolean property to keep track of whether audio is currently playing.
    var isPlaying = false {
        didSet {
            // Notify subscribers that the object has changed when isPlaying changes.
            objectWillChange.send(self)
        }
    }
    
    // The audio player responsible for playback of audio.
    var audioPlayer: AVAudioPlayer!
    
    // Method to start playback of audio from a given URL.
    func startPlayback(audio: URL) {
        // Set up the audio session to play through the speaker.
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            // Try to override the output audio port to use the speaker.
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            // If there's an error, print a failure message.
            print("Playing over the device's speakers failed")
        }
        
        do {
            // Initialize the AVAudioPlayer with the URL of the audio file.
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            // Set the delegate to self to handle playback completion.
            audioPlayer.delegate = self
            // Start playing the audio.
            audioPlayer.play()
            // Set isPlaying to true since audio is now playing.
            isPlaying = true
        } catch {
            // If there's an error initializing the audio player, print a failure message.
            print("Playback failed.")
        }
    }
    
    // Method to stop the playback of audio.
    func stopPlayback() {
        // Stop the audio player.
        audioPlayer.stop()
        // Set isPlaying to false since audio playback has stopped.
        isPlaying = false
    }
    
    func pausePlayback(){}
    
    func resumePlayblack(){}
    
    func getAudioDuration(){}
    
    // Start a timer to update the playback time
    private func startPlaybackTimer() {
    }

    // Stop and invalidate the playback timer
    private func stopPlaybackTimer() {
    }
    
    // Delegate method called when audio player finishes playing an audio file.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // If the audio finished playing successfully, set isPlaying to false.
        if flag {
            isPlaying = false
        }
    }
}

