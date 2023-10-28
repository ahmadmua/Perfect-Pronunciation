//
//  Settings.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Settings: View {
    @State private var notiOn = true
    @State private var selection: Int? = nil
    
    var body: some View {
        VStack{

            NavigationLink(destination: Login(), tag: 1, selection: self.$selection){}
            
            VStack{
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .foregroundColor(Color.yellow)
                    .frame(width: 100.0, height: 100.0)
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
            }//Vstack
            .padding(.top, 50.0)
            
            List{
                Section(header: Text("Notifications")){
                    Toggle("Turn on notifications", isOn: $notiOn)
                        .font(.title2)
                }//section
                .font(.title2)
                
                Section(header: Text("Update Information")){
                    Text("Update Information")
                }//section
                .font(.title2)
                .onTapGesture {
                    self.selection = 2
                }
                
                
            }
                
            
            Button(action:{
               signOut()
            }){
               Text("Sign Out")
                    .bold()
                    .padding(.horizontal, 35.0)
                    .foregroundColor(Color.black)
                    .frame(minWidth: 300, minHeight: 80)
                    .font(.system(size:30))
                    .background(RoundedRectangle(cornerRadius: 10, style: .circular).fill(Color.yellow))
            }//sign out button
            
            
            Spacer()
            Spacer()
        }//vstack
    }//body
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            selection = 1
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
}//main view

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
