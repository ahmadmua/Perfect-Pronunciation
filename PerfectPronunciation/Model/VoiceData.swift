//
//  VoiceData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-26.
//

import Foundation

struct Voice {
    let name: String
    let data: [Accuracy]
}

struct Accuracy: Identifiable {
    let timestamp: Date
    let weekday: String
    let accuracy: Double
    
    var id: String { weekday }
}

struct PickerOption {
    let name: String
    let tag: Int
}
