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
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.darkGray
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().frame
        
        FirebaseApp.configure()
//        fireDBHelper = FireDBHelper(database: Firestore.firestore())
    }
    
    var body: some Scene {
        WindowGroup {
            Homepage().environmentObject(fireDBHelper).environmentObject(userData)
//            ContentView().environmentObject(fireDBHelper).environmentObject(userData)
        }
    }
}
