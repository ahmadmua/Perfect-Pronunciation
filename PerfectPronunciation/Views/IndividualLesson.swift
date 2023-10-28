//
//  IndividualLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct IndividualLesson: View {
    //    @Binding var msgTaken: String
    
    @State private var selection: Int? = nil

    var body: some View {
//        NavigationStack{
            ZStack{
                
                NavigationLink(destination: VoiceRecorder(), tag: 1, selection: self.$selection){}
                
                Color("background")
            Grid{
                Spacer()
                VStack{
                    GridRow{
                        Text("Word to pronounce")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 80)
                    }
                    GridRow{
                        Text("User Pronunciation")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.bottom, 40)
                    }
                    
                    Divider()
                    
                    GridRow{
                        Text("Grade")
                            .background(Rectangle().fill(Color.gray).padding(.all, -30))
                            .padding(.all, 40)
                    }
                    
                }
                Spacer()
                GridRow{
                    
                    Button(action: {
                        //nav to the next word
                        print("record btn press")
                        self.selection = 1
                        //                            self.selection = 1
                    }){
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .foregroundStyle(Color.red)
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        print("Continue btn press")
                        //                            self.selection = 1
                    }){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .foregroundStyle(Color.green)
                    .buttonStyle(.borderless)
                    
                }//grid row
            }//grid
            .background(Color("Background"))
            
                
        }//nanstack
        .background(Color("Background"))
    }
//    }//view
    

}//view

//#Preview {
//    IndividualLesson(msgTaken: <#Binding<String>#>)
//}
