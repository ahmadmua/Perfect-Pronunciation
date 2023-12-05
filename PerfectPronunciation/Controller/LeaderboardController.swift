//
//  LeaderboardController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-05.
//

import Foundation
import Firebase

class LeaderboardController: ObservableObject{
    @Published var leaderboardFull = [Leaderboard]()
    @Published var leaderboardTest = ["Nick", "Test", "Muaz"]
    
    
    func getLeaderboard(){
        //get reference to DB
        let db = Firestore.firestore()
        //read docs at a specific path
        db.collection("UserData").getDocuments { snapshot, error in
            //check for errors
            if error == nil{
                //no error
                if let snapshot = snapshot {
                    
                    //update list property
                    DispatchQueue.main.async{
                    
                        //get documents and create Leaderboard
                        self.leaderboardFull = snapshot.documents.map{ d in
                            //create a new item for the list for each doc returned
                            return Leaderboard(id: d.documentID,
                                               country: d["Country"] as? String ?? "",
                                               weeklyChallengeComplete: d["WeeklyChallengeComplete"] as? Float ?? 0.0)
                        }
                        
//                        print(self.leaderboard)
                    }
                }
            }else{
                //handle any errors
            }
        }
        
    }
    
}
