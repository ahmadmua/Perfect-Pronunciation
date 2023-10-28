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
                    
                }
                //        .safeAreaInset(edge: .top){
                //
            }
            
//}
        
   
    


//#Preview {
//    WeeklyGamePage()
//}
