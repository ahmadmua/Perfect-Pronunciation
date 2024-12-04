import Firebase
import FirebaseFirestore
import FirebaseRemoteConfig
import SwiftUI

@main
struct PerfectPronunciationApp: App {
    
    let fireDBHelper = DataHelper()
    @StateObject private var sharedData = SharedData()
    @StateObject private var comparedAudioAnalysis = AudioAPIController()
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Initialize RemoteConfig
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        
        // Fetch and activate RemoteConfig values (if needed)
        remoteConfig.fetchAndActivate { (status, error) in
            if let error = error {
                print("Error fetching RemoteConfig: \(error.localizedDescription)")
            } else {
                print("RemoteConfig fetch and activate completed with status: \(status.rawValue)")
            }
        }

        // Appearance setup for navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.darkGray
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            Login().environmentObject(fireDBHelper)
                   .environmentObject(sharedData)
                   .environmentObject(comparedAudioAnalysis)
        }
    }
}
