//
//  Leaderboard.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-05.
//

import Foundation
//defines a leaderboard object, which stores a users score to be displayed on the leaderbaord
struct Leaderboard: Identifiable {
    var id : String
    var userName : String
    var country : String
    var weeklyChallengeComplete : Double
    
}
