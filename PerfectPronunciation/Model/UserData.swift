//
//  UserData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI
import CryptoKit  // Import CryptoKit for hashing

struct UserData {
    
    
    var registeredEmail: String = ""
    var registeredPassword: String = ""
    var country: String = ""
    var difficulty: String = ""
    var language: String = ""
    
    mutating func setEmail(registeredEmail: String) {
        self.registeredEmail = registeredEmail
    }
    
    
    mutating func setPass(registeredPassword: String) {
        self.registeredPassword = hashPassword(registeredPassword)
    }
    
    mutating func setCountry(country: String) {
        self.country  = country
    }
    
    mutating func setDifficulty(difficulty: String) {
        self.difficulty  = difficulty
    }
    
    mutating func setLanguage(language: String) {
        self.language  = language
    }
    
    func getCountry() -> String {
        return country
    }
    
    func getDifficulty() -> String {
        return difficulty
    }
    
    func getLanguage() -> String {
        return language
    }
    
    func getEmail() -> String {
        return registeredEmail
    }
    
    func getPass() -> String {
        return registeredPassword
    }
    
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }
}
