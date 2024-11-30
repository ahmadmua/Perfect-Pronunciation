//
//  HardWordsView.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-11-29.
//

import SwiftUI

struct HardWordsView: View {
    @EnvironmentObject var fireDBHelper: DataHelper
    
    var body: some View {
        VStack{
            List(fireDBHelper.wordList, id: \.self) { item in
                Text(item)
            }//list
            .onAppear{
                
                fireDBHelper.getHardWords() { (documents, error) in
                    if documents != nil {
                        print("Document is not empty, Getting hard word list")
                    } else if let error = error {
                        // Handle the error
                        print("Hard words page Error: \(error)")
                    }
                }
                
            }//on appear
            
        }//vstack
    }//body
    
}//view

#Preview {
    HardWordsView()
}
