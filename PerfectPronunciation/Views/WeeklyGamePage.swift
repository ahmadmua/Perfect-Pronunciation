//
//  WeeklyGamePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct WeeklyGamePage: View {

    
    @State private var selection: Int? = nil
    
    var body: some View {
//        NavigationStack{
            
            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}
        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}
        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}
        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}
        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}
            
            ScrollView{
                
                VStack{
                    
                    //                ZStack{
                    //
                    //                    RoundedRectangle(cornerRadius: 25)
                    //                        .fill(Color("CustYell"))
                    //                        .frame(width: 400, height: 200)
                    //                    Text("Weekly Challenge")
                    //                        .foregroundStyle(Color.white)
                    //                        .font(.title)
                    //                }
                    
                    Text("Blurb about how to play! blehblahbleh blahblah blehblahbleh blahblahblehblahbleh blahblahblehblahbleh blahblahblehblahbleh blahblah")
                        .padding(.vertical, 30)
                    
                    Button("Start Challenge"){
                        self.selection = 1
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                    
                    
                    Divider()
                    
                    Grid{
                        GridRow{
                            HStack{
                                Text("Rank")
                                Text("Name")
                                Text("Score")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("1")
                                Text("Nick")
                                Text("10")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("2")
                                Text("Jordan")
                                Text("8")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("3")
                                Text("Muaz")
                                Text("7")
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    
                    
                    
                }
                
            

                
                                
//                List{
//                    ForEach(1..<5){index in
//                        Text("Row \(index)")
//                    }
//                }
//                        Spacer()
                        
                        
                        
                    }
            .navigationTitle("Weekly Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CustYell"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
                    
        
        HStack {
                    Spacer()
                    
                    Button(action: {
                        self.selection = 2
                    }) {
                        Image(systemName: "book.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 6
                    }) {
                        Image(systemName: "gamecontroller.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color("CustYell"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 4
                    }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 5
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color.gray)
                    }
                    
                    Spacer()
                }
                }
                //        .safeAreaInset(edge: .top){
                //
            }
            
//}
        
   
    


//#Preview {
//    WeeklyGamePage()
//}
