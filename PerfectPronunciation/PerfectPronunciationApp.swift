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
    
    let fireDBHelper = DataHelper()
    @StateObject private var sharedData = SharedData()
    
    init() {
        
        FirebaseApp.configure()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.darkGray
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().frame
        
        
        
//        fireDBHelper = FireDBHelper(database: Firestore.firestore())
    }
    
    var body: some Scene {
        WindowGroup {
//            Login().environmentObject(fireDBHelper).environmentObject(sharedData)
//            ContentView().environmentObject(fireDBHelper).environmentObject(userData)
//            TestFirebaseView()
            //Homepage()
            //Homepage().environmentObject(fireDBHelper).environmentObject(sharedData)
            VoiceRecorder(audioRecorder: AudioController(), audioPlayer: AudioPlayBackController(), audioAnalysisData: AudioAPIController(), testText: "The blue bird, lays three blue eggs in her nest. The three eggs hatch and all the blue birds fly away. All the three little birds")
        }
    }
}
