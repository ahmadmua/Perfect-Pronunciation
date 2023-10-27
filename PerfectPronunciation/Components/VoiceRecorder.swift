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
        NavigationStack{
            ZStack{
                
                Image("AppBackground")
                               .resizable()
                               .aspectRatio(contentMode: .fill)
                               .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    
                    Text("Recording")
                        .padding(.top, 20)
                    
                    Text(timeString(time: elapsedTime))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding(.top, 10)
                    
                    WaveformView(audioLevels: $audioLevels)
                        .frame(width: UIScreen.main.bounds.width - 25 , height: 350)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 20)
                    
                    
                    ZStack{
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .frame(width: UIScreen.main.bounds.width - 25, height: 150)
                        
                                       .clipShape(RoundedRectangle(cornerRadius: 20))
                        HStack(spacing: 40) {
                            
                            if !isRecording{
                                Button(action: {
                                    // Implement reset/cancel action
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.red)
                                }
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                            
                            Button(action: {
                                if isRecording {
                                    stopRecording()
                                } else {
                                    startRecording()
                                }
                            }) {
                                Image(systemName: isRecording ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 75))
                                    .foregroundColor(.yellow)
                            }
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            
                            if !isRecording{
                                Button(action: {
                                    // Implement save/finish action
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.green)
                                }
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            }
                        }
                        
                    }
                    .padding(.top, 40)
                    
                    
                  
                }
                .padding()
                }
            }
        }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.caf")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = nil
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true

            // Update UI for audio levels
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                if !self.isRecording {
                    timer.invalidate()
                }
                audioRecorder?.updateMeters()
                let level = CGFloat(audioRecorder?.averagePower(forChannel: 0) ?? 0)
                audioLevels.append((level + 160) / 160)
                audioLevels.removeFirst()
            }
        } catch {
            print("Could not start recording")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1))
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

