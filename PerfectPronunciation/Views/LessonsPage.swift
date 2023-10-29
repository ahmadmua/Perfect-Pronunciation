//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct LessonsPage: View {
//    @State private var msg = ""
    @State private var selection: Int? = nil
    
    
    var body: some View {
//        NavigationStack{

            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}
        
                List{
                    Grid{
                        VStack{
                            GridRow{
                                Text("Phonetics")
                            }//grid row 1
                            
                            Divider()
                            
                            GridRow{
                                Button(action: {
                                    print("phonetic btn press")
                                    self.selection = 1
                                }){
                                    Image(systemName: "mouth.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn
                                .buttonStyle(.borderless)
                                
                                
                            }//grid row 2
                            .padding()
                        }//Vstack
                        
                        VStack{
                            GridRow{
                                Text("Basics")
                            }//grid row 3
                        }//vstack
                        
                        Divider()
                        
                        GridRow{
                            Button(action: {
                                print("basic1 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "mic.circle.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn
                            
                            Button(action: {
                                print("basic2 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "mic.circle.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn basic2
                            .buttonStyle(.borderless)
                        }//grid row 4
                        .padding()
                        
                        VStack{
                            GridRow{
                                Text("Food")
                            }//grid row 3
                        }//vstack
                        
                        Divider()
                        
                        GridRow{
                            Button(action: {
                                print("food1 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn
                            
                            Button(action: {
                                print("food2 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn food 2
                            .buttonStyle(.borderless)
                        }//grid row
                        .padding()
                        GridRow{
                            Button(action: {
                                print("food3 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn3
                            
                            Button(action: {
                                print("food4 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn food 4
                            .buttonStyle(.borderless)
                        }//grid row
                        .padding()
                        
                    }//grid
                    .background(Color("Background"))
                    .padding(.vertical, -15)
                    .padding(.horizontal, -20)
                    
                }//list
                .background(Color("Background"))
                .scrollContentBackground(.hidden)
            
                .navigationTitle("Lessons")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color("CustYell"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        
//        TabView{
//            //            LessonsPage()
//            //                .tabItem{
//            //                    Image(systemName: "book.fill")
//            //                }
//                        WeeklyGamePage()
//                            .tabItem{
//                                Image(systemName: "gamecontroller.fill")
//                            }
//                        StorePage()
//                            .tabItem{
//                                Image(systemName: "dollarsign.fill")
//                            }
//                        AchievementPage()
//                            .tabItem{
//                                Image(systemName: "trophy.fill")
//                            }
//                    }

            
//        }//nav view
    }
}

//#Preview {
//    LessonsPage()
//}
