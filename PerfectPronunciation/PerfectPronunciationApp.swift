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
//            TestView().environmentObject(fireDBHelper)
//            ContentView().environmentObject(fireDBHelper).environmentObject(userData)
//            TestFirebaseView()
            Homepage()
        }
    }
}
