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
    @StateObject private var sharedData = SharedData()
    
    
    
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
            Login().environmentObject(fireDBHelper).environmentObject(sharedData)
//            ContentView().environmentObject(fireDBHelper).environmentObject(userData)
//            TestFirebaseView()
            //Homepage()
            //Homepage().environmentObject(fireDBHelper).environmentObject(userData)
            VoiceRecorder(audioRecorder: AudioController())
        }
    }
}
