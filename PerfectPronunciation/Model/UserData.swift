//
//  UserData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

class UserData: ObservableObject {
    @Published var registeredEmail: String = ""
}

class User: Identifiable{
    
    var country: String = ""
    var difficulty: String = ""
    
    
    init(country: String, difficulty: String){
        self.country = country
        self.difficulty = difficulty
    }
    
}
