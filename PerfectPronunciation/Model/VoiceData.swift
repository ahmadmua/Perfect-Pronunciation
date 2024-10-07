//
//  VoiceData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-26.
//

import Foundation

struct Voice {
    let name: String
    var data: [Accuracy]
}

struct Accuracy: Identifiable {
    
    var timestamp: Date
    var weekday: String
    var AccuracyScore: Float
    
    var id: String { weekday }
}

struct PickerOption {
    let name: String
    let tag: Int
}
