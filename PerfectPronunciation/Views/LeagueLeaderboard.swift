//
//  LeagueLeaderboard.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-11-11.
//

import SwiftUI

struct LeagueLeaderboard: View {
    @ObservedObject var leaderboardModel = LeaderboardController()
    @EnvironmentObject var fireDBHelper: DataHelper
    @ObservedObject var xpModel = ExperienceController()
    
    @State private var userPercentile: Double = 0.0
    
    var body: some View {
        VStack {
            // Top 3 Podium
            if leaderboardModel.leagueFull.count >= 3 {
                VStack {
                    Text("Top 3 Players")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    HStack(alignment: .bottom, spacing: 16) {
                        // 2nd Place - Left
                        if leaderboardModel.leagueFull.indices.contains(1) {
                            podiumTile(content: leaderboardModel.leagueFull[1], height: 120, color: .gray)
                        }
                        
                        // 1st Place - Center
                        if leaderboardModel.leagueFull.indices.contains(0) {
                            podiumTile(content: leaderboardModel.leagueFull[0], height: 150, color: .yellow)
                        }
                        
                        // 3rd Place - Right
                        if leaderboardModel.leagueFull.indices.contains(2) {
                            podiumTile(content: leaderboardModel.leagueFull[2], height: 100, color: .brown)
                        }
                    }
                }
                .padding()
            }//top 3 players
            
            Divider().padding(.vertical)
            
            //percentile
            Text("You are in the top \(String(format: "%.0f", userPercentile))% of Language earners! \n You have earned a total of \(xpModel.userTotalXp) XP")
                .multilineTextAlignment(.center)
                    
            
            // List displaying the rest of the leaderboard
            List(leaderboardModel.leagueFull) { content in
                HStack {
                    
                    Text("\(leaderboardModel.getFlagForCountry(fullCountryName: content.country)) \(content.userName)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(content.league) - \(content.experience)xp")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding()
                .background(colorForLeague(content.league))
                .cornerRadius(10)
            }
            .listStyle(.plain)

        }
        .onAppear {
            leaderboardModel.getLeagueLeaderboard()
            xpModel.getTotalUserExperience()

            
            if let percentile = leaderboardModel.calculateUserPercentile() {
                self.userPercentile = percentile
                print("User is in the \(percentile)th percentile")
            } else {
                print("User not found or leaderboard is empty")
            }
        }
        .navigationTitle("Leage Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .padding(.top, 10)
    }
    
    init() {
        leaderboardModel.getLeagueLeaderboard()
    }
    
    // Helper function to create a podium tile
    func podiumTile(content: League, height: CGFloat, color: Color) -> some View {
        VStack {
            Text("\(leaderboardModel.getFlagForCountry(fullCountryName: content.country)) \(content.userName)")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 80, height: height)
        .background(color)
        .cornerRadius(10)
        .padding(.horizontal, 4)
    }
    
    // Helper function to return color based on league
    func colorForLeague(_ league: String) -> Color {
        switch league {
        case "True Alpaca":
            return .blue
        case "Gold":
            return .yellow
        case "Silver":
            return .gray
        case "Bronze":
            return .brown
        default:
            return .primary
        }
    }
}
