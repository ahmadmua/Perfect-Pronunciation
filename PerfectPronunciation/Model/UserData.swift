//
//  UserData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

struct UserData  {
    
     var registeredEmail: String = "jk@gmail.com"
     var country: String = ""
     var difficulty: String = ""
     var language: String = ""
    
    mutating func setCountry(country: String){
        self.country  = country
    }
    
    mutating func setDifficulty(difficulty: String){
        self.difficulty  = difficulty
    }
    
    mutating func setLanguage(language: String){
        self.language  = language
    }
    
    func getCountry() -> String{
        return country
    }
    
    func getDifficulty() -> String{
        return difficulty
    }
    
    func getLanguage() -> String {
        return language
    }
}

