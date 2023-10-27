//
//  UserData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

class UserData: ObservableObject {
    
    @Published var registeredEmail: String = ""
    @Published var country: String = ""
    @Published var difficulty: String = ""
    
    func setCountry(country: String){
        self.country  = country
    }
    
    func setDifficulty(difficulty: String){
        self.difficulty  = difficulty
    }
    
    func getCountry() -> String{
        return country
    }
    
    func getDifficulty() -> String{
        return difficulty
    }
}

