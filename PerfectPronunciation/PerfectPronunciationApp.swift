//
//  PerfectPronunciationApp.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import Firebase
import FirebaseFirestore
import SwiftUI


@main
struct PerfectPronunciationApp: App {
    
    let fireDBHelper = FireDBHelper()
    @StateObject private var userData = UserData()
    
    init() {
        FirebaseApp.configure()
//        fireDBHelper = FireDBHelper(database: Firestore.firestore())
    }
    
    var body: some Scene {
        WindowGroup {
            Details().environmentObject(fireDBHelper).environmentObject(userData)
        }
    }
}
