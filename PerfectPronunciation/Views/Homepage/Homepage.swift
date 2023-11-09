//
//  Homepage.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Homepage: View {
    let data = ["Lessons", "Weekly", "Badges", "Store"]
    @State private var userEmail: String = ""
    @State var pronunciationPoints : Int = 0
    @State private var selection: Int? = nil
    @ObservedObject private var viewModel = AccuracyViewModel()
    
    @State private var showLesson = false
    @State private var showStats = false
    @State private var showSettings = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    
    var body: some View {
       //NavigationStack { // Use NavigationView
            ScrollView(.vertical, showsIndicators: false) {
                ZStack{
                    
//                    NavigationLink(destination: LessonsPage(), tag: 1, selection: self.$selection){}
//                    NavigationLink(destination: WeeklyGamePage(), tag: 2, selection: self.$selection){}
//                    NavigationLink(destination: AchievementPage(), tag: 3, selection: self.$selection){}
//                    NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
//                    NavigationLink(destination: StatData(), tag: 5, selection: self.$selection){}
//                    NavigationLink(destination: Settings(), tag: 6, selection: self.$selection){}
                    
//                    Image("AppBackground")
//                        //.resizable()
//                        //.scaledToFill()
//                        //.frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
//                        //.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("Hello, \(userEmail)")
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
                                                        self.showLesson.toggle()
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
                                                    .navigationDestination(isPresented: $showLesson){
                                                        LessonsPage()
                                                            .navigationBarBackButtonHidden(true)
                                                    }
                                                    
                                                    Button(action: {
//                                                        self.selection = 2
                                                        self.showWeekly.toggle()
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
                                                    .navigationDestination(isPresented: $showWeekly){
                                                        WeeklyGamePage()
                                                            .navigationBarBackButtonHidden(true)
                                                    }
                                                }//hstack
                                            }//grid row
                                            
                                            GridRow{
                                                HStack{
                                                    Button(action: {
//                                                        self.selection = 3
                                                        self.showAchievement.toggle()
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
                                                    .navigationDestination(isPresented: $showAchievement){
                                                        AchievementPage()
                                                            .navigationBarBackButtonHidden(true)
                                                    }
                                                    
                                                    Button(action: {
//                                                        self.selection = 4
                                                        self.showStore.toggle()
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
                                                    .navigationDestination(isPresented: $showStore){
                                                        StorePage()
                                                            .navigationBarBackButtonHidden(true)
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
//                                            self.selection = 5
                                            self.showStats.toggle()
                                        }){
                                            BarChart(
                                                data: viewModel.word.data,
                                                range: viewModel.accuracyRange
                                            )
                                            
                                        }
                                        .navigationDestination(isPresented: $showStats){
                                            StatData()
//                                                .navigationBarBackButtonHidden(true)
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
//                            self.selection = 6
                            self.showSettings.toggle()
                        }){
                
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Circle().fill(Color.yellow))
                        }
                        .navigationDestination(isPresented: $showSettings){
                            Settings()
//                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    )
                    
                    Spacer()
                }
            }
            
        //}
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = Auth.auth().currentUser {
                if let email = user.email {
                    userEmail = email.components(separatedBy: "@").first ?? ""
                } else {
                }
            }
        }
        
        Spacer()
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
