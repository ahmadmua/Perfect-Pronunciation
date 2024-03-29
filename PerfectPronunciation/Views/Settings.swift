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
    @AppStorage("notificationsEnabled") private var notiOn = true
    @State private var selection: Int? = nil
    @State var email: String = ""
    let notificationController = NotificationController()
    
    var body: some View {
        VStack{

            NavigationLink(destination: Login(), tag: 1, selection: self.$selection){}
            NavigationLink(destination: UpdateInfo(), tag: 2, selection: self.$selection){}
            
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
                .onChange(of: notiOn, perform: { newValue in
                            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                            notificationController.scheduleNotification(enabled: newValue)
                        })
                
                Section(header: Text("Update Password")){
                    Text("Update Password")
                }//section
                .font(.title2)
                .onTapGesture {
                    self.selection = 2
                }
                
                
            }
                
            
            Button(action:{
               signOut()
                selection = 1
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
