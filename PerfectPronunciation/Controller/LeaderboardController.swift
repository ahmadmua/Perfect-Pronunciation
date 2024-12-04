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
    @Published var leagueFull = [League]()
    
    
    func getLeaderboard(){
        
        //get reference to DB
        let db = Firestore.firestore()
        //read docs at a specific path
        db.collection("UserData").order(by: "WeeklyChallengeComplete", descending: true).getDocuments { snapshot, error in
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
                                               userName: d["Username"] as? String ?? "",
                                               country: d["Country"] as? String ?? "",
                                               weeklyChallengeComplete: d["WeeklyChallengeComplete"] as? Double ?? 0.0)
                        }
                        
//                        print(self.leaderboard)
                    }
                }
            }else{
                //handle any errors
            }
        }
        
    }
    
    
    //MARK: - for league system
    func getLeagueLeaderboard() {
            let db = Firestore.firestore()
            db.collection("UserData")
                .order(by: "TotalExperience", descending: true)
                .getDocuments { snapshot, error in
                    if error == nil, let snapshot = snapshot {
                        DispatchQueue.main.async {
                            // Get documents and create leaderboard
                            var users = snapshot.documents.map { d in
                                return League(
                                    id: d.documentID,
                                    userName: d["Username"] as? String ?? "",
                                    country: d["Country"] as? String ?? "",
                                    experience: d["TotalExperience"] as? Int ?? 0,
                                    league: "" // Empty for now, will be set in determineLeagueByExperience
                                )
                            }
                            
                            // Determine league for each user based on experience ranking
                            self.determineLeague(users: &users)
                            self.leagueFull = users
                        }
                    } else {
                        print("Error loading documents: \(String(describing: error))")
                    }
                }
        }
    
    func determineLeague(users: inout [League]) {
            // Sort users by experience in descending order
            users.sort { $0.experience > $1.experience }
            
            let totalUsers = users.count
            for (index, user) in users.enumerated() {
                let rankPercentage = Double(index) / Double(totalUsers)
                
                // Assign league based on percentage ranking
                if rankPercentage < 0.1 {
                    users[index].league = "True Alpaca"
                }else if rankPercentage < 0.2 {
                    users[index].league = "Gold"
                } else if rankPercentage < 0.6 {
                    users[index].league = "Silver"
                } else {
                    users[index].league = "Bronze"
                }
                
                // Optionally, update Firebase with the assigned league
                let db = Firestore.firestore()
                db.collection("UserData").document(user.id).updateData(["League": users[index].league])
            }
        }
    
    func getFlagForCountry(fullCountryName: String) -> String {
        
        var countryName = fullCountryName
        if(fullCountryName == "China"){
            countryName = "China mainland"
        }
        let country = getCountryCode(code: countryName)
        
        
        let base : UInt32 = 127397
            var s = ""
            for v in country.unicodeScalars {
                s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
            }
            return String(s)
        }
        
    func getCountryCode(code : String) -> String {
        let locales : String = ""
        for localeCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale(localeIdentifier: "en_UK")
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
            
            if code.lowercased() == countryName?.lowercased() {
                return localeCode
            }
        }
        return locales
    }
    
    func calculateUserPercentile() -> Double? {
        // check that leaderboard is not empty
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            guard !leagueFull.isEmpty else { return 0.0 }
            
            // users ranking in the leaderboard
            let sortedLeaderboard = leagueFull.sorted { $0.experience > $1.experience }
            guard let userIndex = sortedLeaderboard.firstIndex(where: { $0.id == userID }) else { return 0.0 }
            
            // percentile
            let totalUsers = sortedLeaderboard.count
            let usersBelow = totalUsers - (userIndex + 1)
            let percentile = (Double(usersBelow) / Double(totalUsers)) * 100
            
            return 100 - percentile
        } else {
            // Handle the case where the user is not authenticated
            print("User is not authenticated")
            return 0.0
        }
    }
    
}
