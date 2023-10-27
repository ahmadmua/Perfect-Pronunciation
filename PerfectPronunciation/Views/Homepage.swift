//
//  Homepage.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

struct Homepage: View {
    
    @State var pronunciationPoints : Int = 0
    
    var body: some View {
        NavigationStack{
            VStack{
                
                
            
            }
            .navigationBarItems(leading:
                                    Image("Alpaca")
                                        .resizable()
                                        .padding(4)
                                        .frame(width: 45, height: 40)
                                        .clipShape(Circle())
                                        .background(Circle().fill(Color.yellow))
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
            )
            .navigationBarItems(trailing:
                HStack(spacing: 20){
                    
                    HStack{
                        Image(systemName: "music.mic.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                        
                        Text(" \(String(pronunciationPoints)) pts")
                            .foregroundColor(.black)
                    }
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.yellow))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2))
                
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .background(Circle().fill(Color.yellow))
                        //.overlay(Circle().stroke(Color.black, lineWidth: 2))

                    
                }
                                
            )
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
