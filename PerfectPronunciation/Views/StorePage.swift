//
//  StorePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct StorePage: View {
    
    @State private var selection: Int? = nil
    
    var body: some View {
        
        
        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}
        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}
        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}
        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}
//        NavigationStack{
            
//            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}
  
                List{
                    Grid{
                        VStack{
                            GridRow{
                                Text("Themes")
                            }//grid row 1
                            
                            Divider()
                            
                            GridRow{
                                HStack{
                                    Button(action: {
                                        print("theme1 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 1")
                                    
                                    HStack(alignment: .center){
                                        Text("20")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                
//                                GridRow{
                                    HStack{
                                        Button(action: {
                                            print("Theme2 btn press")
                                            //                                    self.selection = 1
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Theme 2")
                                        
                                        HStack(alignment: .center){
                                            Text("20")
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 25, weight: .light))
                                            
                                        }
                                        .padding(.leading, 60)
                                    }
                                
                                HStack{
                                    Button(action: {
                                        print("theme 3 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 3")
                                    
                                    HStack(alignment: .center){
                                        Text("20")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                              
                                
                            }//grid row 2
                            .padding()

                                                    
                            
                        }//Vstack
                        
                        VStack{
                            GridRow{
                                Text("Items")
                            }//grid row 1
                            
                            Divider()
                            
                            GridRow{
                                HStack{
                                    Button(action: {
                                        print("item1 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Item 1")
                                    
                                    HStack(alignment: .center){
                                        Text("30")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                
//                                GridRow{
                                    HStack{
                                        Button(action: {
                                            print("item2 btn press")
                                            //                                    self.selection = 1
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Item 2")
                                        
                                        HStack(alignment: .center){
                                            Text("30")
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 25, weight: .light))
                                            
                                        }
                                        .padding(.leading, 60)
                                    }
                                
                                HStack{
                                    Button(action: {
                                        print("item 3 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Item 3")
                                    
                                    HStack(alignment: .center){
                                        Text("30")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                              
                                
                            }//grid row 2
                            .padding()

                            
                           
                            
                        }//Vstack
                        
                       
                        
   
                     
                        
                    }//grid
                    
                    .background(Color("Background"))
                    .padding(.vertical, -15)
                    .padding(.horizontal, -20)
                    
                }//list
                .background(Color("Background"))
                .scrollContentBackground(.hidden)
            
                .navigationTitle("Store")
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
                        self.selection = 6
                    }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 5
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                }
        }
    }
//}

////#Preview {
//    StorePage()
//}
