//
//  Homepage.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

struct Homepage: View {
    let data = ["Lessons", "Weekly", "Badges", "Store"]
    
    @State var pronunciationPoints : Int = 0
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                
                Text("Hello \("Name-Placehold")")
                    .padding(.leading)
                    .font(.headline)
                    .bold()
                
                Section{
                    VStack(alignment: .leading){
                        Text("Explore")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)
                            
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 20) {
                                ForEach(data, id: \.self) { item in
                                    VStack {
                                        Text(item)
                                            .font(.headline)
                                            .padding()
                                            .frame(width: 150, height: 75) // Adjust as needed
                                            .background(Color.yellow)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                Section{
                    VStack(alignment: .leading){
                        Text("Goals / Stats")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)
                            
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 20) {
                                
                                VStack(alignment: .center){
                                    Text("Graph Place-Holder")
                                }
                                .frame(width: 200, height: 75)
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Text("Data Point 1")
                                    
                                    Text("Data Point 1")
                                    
                                    Text("Data Point 1")
                                    
                                    Text("Data Point 1")
                                    
                                }
                                .padding(.leading)
                            }
                            .padding()
                        }
                    }
                }
            
            }
            .padding(.top, 20)
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
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        
        Spacer()
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
