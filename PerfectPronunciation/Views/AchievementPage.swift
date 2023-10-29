//
//  AchievementPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct AchievementPage: View {
    @State private var selection: Int? = nil
    var body: some View {
        
//        NavigationStack{
        
        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}
        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}
        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}
        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}
        
            List{
                Grid{
                    VStack{
                        GridRow{
                            HStack{
                                Button(action: {
                                    print("basic1 btn press")
                                    //                            self.selection = 1
                                }){
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn
                                .buttonStyle(.borderless)
                                VStack{
                                    Text("Achievement Name")
                                        .padding(.horizontal, 20)
                                    Text("Achievement Description")
                                        .padding(.horizontal, 20)
                                }
                            }//hstack
                        }
                        .padding()
                        GridRow{
                            HStack{
                                Button(action: {
                                    print("basic2 btn press")
                                    //                            self.selection = 1
                                }){
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn basic2
                                .buttonStyle(.borderless)
                                VStack{
                                    Text("Achievement Name")
                                        .padding(.horizontal, 20)
                                    Text("Achievement Description")
                                        .padding(.horizontal, 20)
                                }
                            }//hstack
                        }//grid row 4
                        .padding()
                        GridRow{
                            HStack{
                                Button(action: {
                                    print("basic2 btn press")
                                    //                            self.selection = 1
                                }){
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn basic2
                                .buttonStyle(.borderless)
                                VStack{
                                    Text("Achievement Name")
                                        .padding(.horizontal, 20)
                                    Text("Achievement Description")
                                        .padding(.horizontal, 20)
                                }
                            }//hstack
                        }//grid row 4
                        .padding()
                        GridRow{
                            HStack{
                                Button(action: {
                                    print("basic2 btn press")
                                    //                            self.selection = 1
                                }){
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn basic2
                                .buttonStyle(.borderless)
                                VStack{
                                    Text("Achievement Name")
                                        .padding(.horizontal, 20)
                                    Text("Achievement Description")
                                        .padding(.horizontal, 20)
                                }
                            }//hstack
                        }//grid row 4
                        .padding()
                        GridRow{
                            HStack{
                                Button(action: {
                                    print("basic2 btn press")
                                    //                            self.selection = 1
                                }){
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn basic2
                                .buttonStyle(.borderless)
                                VStack{
                                    Text("Achievement Name")
                                        .padding(.horizontal, 20)
                                    Text("Achievement Description")
                                        .padding(.horizontal, 20)
                                }
                            }//hstack
                        }//grid row 4
                        .padding()
                    }//vstack
                }//grid
                .background(Color("Background"))
                .padding(.vertical, -15)
                .padding(.horizontal, -20)
                
                
            }//list
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        
            .navigationTitle("Achievements")
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
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 3
                    }) {
                        Image(systemName: "gamecontroller.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 4
                    }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 6
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                }
        }
    }
//}

//#Preview {
//    AchievementPage()
//}
