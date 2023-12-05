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
    
    
}
