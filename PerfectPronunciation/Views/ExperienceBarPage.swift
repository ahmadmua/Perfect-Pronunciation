//
//  ExperienceBarPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-10-21.
//

import SwiftUI

struct ExperienceBarPage: View {
    @ObservedObject var xpController : ExperienceController
    
    @State private var showDetails = false
    
    // timer to wait for firebase
    @State var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Display user experience
            Text("Level \(xpController.userLevel)")
                .font(.headline)
                .padding(.bottom, 10)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    if (timeRemaining == 1){
                        xpController.getUserExperience()
                        xpController.getUserLevel()
                    }
                }
            
            // XP Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background of the bar
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: geometry.size.width, height: 20)
                        .foregroundColor(Color.gray.opacity(0.3))
                    
                    // Foreground - Animated XP bar
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: self.barWidth(for: geometry.size.width), height: 20)
                        .foregroundColor(.blue)
                        .animation(.easeInOut(duration: 1.0), value: xpController.userXp)
                }
            }
            .frame(height: 20)
            .padding(.horizontal)
            
            // Display current XP
            Text("\(xpController.userXp) / 500 XP")
                .font(.subheadline)
                .padding(.top, 10)
            
            // Button to simulate gaining XP
            Button(action: {
                self.showDetails = true
            }) {
                Text("Great!")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .navigationDestination(isPresented: $showDetails){
                Details()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .padding()
        .onAppear {
            xpController.getUserExperience() // Fetch user experience on view appear
            xpController.calculateUserLevel()
            xpController.getUserLevel()
            
        }
    }
    
    // Calculate the width of the XP bar relative to the user's XP
    func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let xpPerLevel = 500
        let xpProgress = min(CGFloat(xpController.userXp) / CGFloat(xpPerLevel), 1.0)
        return totalWidth * xpProgress
    }
}

