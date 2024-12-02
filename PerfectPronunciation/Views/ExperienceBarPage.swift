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
    @State private var isAnimatingText = false
    @State private var isAnimatingCoin = false
    
    @State private var previousLevel: Int = 0
    
    @State private var userDifficulty: String? = nil
    // timer to wait for firebase
    @State var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    var body: some View {
        VStack {
            Spacer()
            
            //display currency gain
            if #available(iOS 17.0, *) {
                Image(systemName: "music.mic.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("CustYell"))
                    .symbolEffect(.bounce, value: isAnimatingCoin)
            } else {
                // Fallback on earlier versions
                Image(systemName: "music.mic.circle")
                    .resizable()
                    .frame(width: 50, height: 5)
                    .foregroundColor(Color("CustYell"))
            }
            
            
            if let difficulty = userDifficulty {
                switch difficulty {
                case "Beginner":
                    Text("+100 Currency")
                case "Intermediate":
                    Text("+200 Currency")
                case "Advanced":
                    Text("+300 Currency")
                default:
                    Text("+ Currency")
                }
            }else{
                Text ("Loading...")
            }
            
            
            
            Spacer()
            
            
            // Display user experience
            Text("Level \(xpController.userLevel)")
                .padding(.bottom, 10)
                .font(.system(size: isAnimatingText ? 100 : 20))
                .foregroundStyle(isAnimatingText ? Color.yellow : Color.black)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    if timeRemaining == 1 {
                        xpController.getUserExperience() // Fetch user experience on view appear
                        xpController.getUserLevel()
                        print("Current userLevel: \(xpController.userLevel)")
                        //animation based on levelup (commented out)
//                        if xpController.userLevel > previousLevel {
                            isAnimatingText = true
                            
                            // Delay to reset the animation flag
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isAnimatingText = false
                            }
//                        }
                    }
                }
                .animation(.spring(), value: isAnimatingText)
            
            
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
                        .foregroundColor(Color("CustYell"))
                        .animation(.easeInOut(duration: 1.0), value: xpController.userXp)
                }
            }
            .frame(height: 20)
            .padding(.horizontal)
            
            // Display current XP
            Text("\(xpController.userXp) / 500 XP")
                .font(.subheadline)
                .padding(.top, 10)
            //show the user how much xp they gain
            if let difficulty = userDifficulty {
                switch difficulty {
                case "Beginner":
                    Text("+100 XP")
                case "Intermediate":
                    Text("+200 XP")
                case "Advanced":
                    Text("+300 XP")
                default:
                    Text("+ XP")
                }
            }else{
                Text ("Loading...")
            }
            
            // Button to simulate gaining XP
            Button(action: {
                self.showDetails = true
            }) {
                Text("Great!")
                    .padding()
                    .background(Color("CustYell"))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .navigationDestination(isPresented: $showDetails){
                Details()
                    .navigationBarBackButtonHidden(true)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        
        
        .onAppear {
            self.isAnimatingCoin = true
            
            
            xpController.getUserExperience() // Fetch user experience on view appear
            xpController.getUserLevel()
            previousLevel = xpController.userLevel
            
            // Fetch user difficulty
            xpController.getUserDifficultyForRewards { difficulty in
                self.userDifficulty = difficulty
            }
        }
    }
    
    // Calculate the width of the XP bar relative to the user's XP
    func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let xpPerLevel = 500
        let xpProgress = min(CGFloat(xpController.userXp) / CGFloat(xpPerLevel), 1.0)
        return totalWidth * xpProgress
    }
}



