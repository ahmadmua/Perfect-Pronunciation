//
//  AchievementPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct AchievementPage: View {
    var body: some View {
//        NavigationStack{
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
        
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CustYell"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
//}

//#Preview {
//    AchievementPage()
//}
