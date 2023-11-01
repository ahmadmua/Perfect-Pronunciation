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
    @State private var selection: Int? = nil
    @ObservedObject private var viewModel = AccuracyViewModel()
    
    var body: some View {
        NavigationView { // Use NavigationView
            ScrollView(.vertical, showsIndicators: false) {
                ZStack{
                    
                    NavigationLink(destination: LessonsPage(), tag: 1, selection: self.$selection){}
                    NavigationLink(destination: WeeklyGamePage(), tag: 2, selection: self.$selection){}
                    NavigationLink(destination: AchievementPage(), tag: 3, selection: self.$selection){}
                    NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
                    NavigationLink(destination: StatData(), tag: 5, selection: self.$selection){}
                    NavigationLink(destination: Settings(), tag: 6, selection: self.$selection){}
                    
//                    Image("AppBackground")
//                        //.resizable()
//                        //.scaledToFill()
//                        //.frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
//                        //.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("Hello Name-Placehold")
                            .font(.headline)
                            .bold()
                        ZStack{
//                            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
//                                .frame(width: UIScreen.main.bounds.width - 10, height: 150)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            VStack(alignment: .leading) {
                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 20) {
//                                        ForEach(data, id: \.self) { item in
//                                            Text(item)
//                                                .font(.headline)
//                                                .padding()
//                                                .frame(width: 150, height: 75)
//                                                .background(Color.yellow)
//                                                .cornerRadius(10)
//                                                .shadow(radius: 5)
//                                        }
                                        
                                        Grid{
                                            GridRow{
                                                HStack{
                                                    Button(action: {
                                                        self.selection = 1
                                                    }){
                                                        Text("Lessons")
                                                            .font(.headline)
                                                            .padding()
                                                           .frame(width: 185, height: 75)
                                                           .background(Color("CustYell"))
                                                           .foregroundStyle(Color.black)
                                                           .cornerRadius(10)
                                                           .shadow(radius: 5)
                                                        
                                                    }
                                                    
                                                    Button(action: {
                                                        self.selection = 2
                                                    }){
                                                        Text("Weekly")
                                                            .font(.headline)
                                                            .padding()
                                                           .frame(width: 185, height: 75)
                                                           .background(Color("CustYell"))
                                                           .cornerRadius(10)
                                                           .foregroundStyle(Color.black)
                                                           .shadow(radius: 5)
                                                        
                                                    }
                                                }//hstack
                                            }//grid row
                                            
                                            GridRow{
                                                HStack{
                                                    Button(action: {
                                                        self.selection = 3
                                                    }){
                                                        Text("Achievments")
                                                            .font(.headline)
                                                            .padding()
                                                           .frame(width: 185, height: 75)
                                                           .background(Color("CustYell"))
                                                           .cornerRadius(10)
                                                           .foregroundStyle(Color.black)
                                                           .shadow(radius: 5)
                                                        
                                                    }
                                                    
                                                    Button(action: {
                                                        self.selection = 4
                                                    }){
                                                        Text("Store")
                                                            .font(.headline)
                                                            .padding()
                                                           .frame(width: 185, height: 75)
                                                           .background(Color("CustYell"))
                                                           .cornerRadius(10)
                                                           .foregroundStyle(Color.black)
                                                           .shadow(radius: 5)
                                                    }
                                                }
                                            }
                                        }//grid
                                        
                                        
                                        
                                        
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                }
                            }
                        }
                        
                        
                        
                        VStack(alignment: .leading){
                            
                            Text("Goals / Stats")
                                .font(.largeTitle)
                                .bold()
                            
                            ZStack{
//                                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
//                                    .frame(width: UIScreen.main.bounds.width - 10, height: 250)
//                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                VStack(alignment: .leading) {
                                
                                    
                                    HStack(spacing: 20) {
                                        
                                        //                                        Text("Graph Place-Holder")
                                        //                                            .frame(width: 200, height: 75)
                                        
                                        //                                        Words(
                                        //                                            weekly: viewModel.word.name,
                                        //                                            sum: viewModel.word.data.sum(\.accuracy)
                                        //                                        )
                                        
        
                                        
                                        Button(action: {
                                            self.selection = 5
                                        }){
                                            BarChart(
                                                data: viewModel.word.data,
                                                range: viewModel.accuracyRange
                                            )
                                            
                                        }
    
                                        VStack(alignment: .center, spacing: 10){
                                            Text("Data Point 1")
                                            Text("Data Point 1")
                                            Text("Data Point 1")
                                            Text("Data Point 1")
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                }
                            }
                        }
                        
                        
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .navigationBarItems(leading:
                                            Image("Alpaca")
                        .resizable()
                        .padding(4)
                        .frame(width: 45, height: 40)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.yellow))
                        .overlay(Circle().stroke(Color.black, lineWidth: 2)),
                                        trailing:
                                            HStack(spacing: 20){
                        HStack{
                            Image(systemName: "music.mic.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.black)
                            
                            Text(" \(String(pronunciationPoints)) pts")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.yellow))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2))
                        
                        Button(action: {
                            self.selection = 6
                        }){
                
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Circle().fill(Color.yellow))
                        }
                    }
                    )
                    
                    Spacer()
                }
            }
            
        }
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        
        Spacer()
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
