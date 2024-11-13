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
    
    var body: some View {
        VStack {
            // TODO: add a refresh button -
            
            // List displaying the leaderboard
            List(leaderboardModel.leagueFull) { content in
                Text("\(leaderboardModel.getFlagForCountry(fullCountryName: content.country)) \(content.userName) \n \(content.league) - \(content.experience)xp")
            }

        }
        .onAppear {
            // Refresh for updating the leaderboard
            leaderboardModel.getLeagueLeaderboard()
        }
        .padding(.top, 10)
    }
    
    init() {
        // Initial population of the leaderboard
        leaderboardModel.getLeagueLeaderboard()
    }
}


