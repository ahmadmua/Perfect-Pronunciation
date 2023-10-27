//
//  VoiceRecorder.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-10-27.
//

import SwiftUI
import AVFoundation

struct VoiceRecorder: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 50)
    @State private var elapsedTime = TimeInterval(0)
    var timer: Timer?
    
    var body: some View {
            VStack {
                
                
                Text("Recording")
                    .padding(.top, 20)
                
                Text(timeString(time: elapsedTime))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .padding(.top, 10)
                
                WaveformView(audioLevels: $audioLevels)
                    .frame(height: 350)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 20)
                
                HStack(spacing: 40) {
                    
                    if !isRecording{
                        Button(action: {
                            // Implement reset/cancel action
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        if isRecording {
                            stopRecording() //TODO
                        } else {
                            startRecording() //TODO
                        }
                    }) {
                        Image(systemName: isRecording ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 75))
                            .foregroundColor(.red)
                    }
                    
                    if !isRecording{
                        Button(action: {
                            // Implement save/finish action
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.top, 40)
            }
            .padding()
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
            .fill(Color.blue)
            .frame(width: 4, height: value * 10)
    }
}

func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }

struct VoiceRecorder_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecorder()
    }
}

