import SwiftUI
import Firebase
import FirebaseAuth


struct Login: View {
    
    @State var email: String = ""
    @State var password: String = "123456"
    @State private var selection: Int? = nil
    @State private var userLoggedIn = false
    @State private var showingAlert = false
    @State private var msg = ""
    @State var userData = UserData()
    let notificationController = NotificationController()
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 30){
                
                NavigationLink(destination: Register(), tag: 1, selection: self.$selection){}
                
                NavigationLink(destination: Country(), tag: 2, selection: self.$selection){}
                
                NavigationLink(destination: Homepage(), tag: 3, selection: self.$selection){}
                
                
                Spacer()
                
                Text("LOGIN")
                    .fontWeight(.bold)
                    .font(Font.system(size: 50))
                    .foregroundColor(Color.yellow)
                    .padding(.bottom, 100)
                
                
                // Form
                VStack(spacing: 25){
                    TextField("Email", text: $email)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                        .multilineTextAlignment(.center)
                        .onAppear {
                            email = userData.registeredEmail
                        }
                    
                    VStack(spacing:10){
                        SecureField("Password", text: $password)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                            .multilineTextAlignment(.center)
                        
                    }
                }
                
                // SignIn
                Button(action: {
                    login()
                }){
                    Text("Sign In")
                        .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56, alignment: .leading)
                        .background(Color.yellow)
                        .cornerRadius(10)
                    
                }
                .alert(self.msg, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                
                Button("Send notification in 5 seconds") {
                    notificationController.sendNotification(
                        date: Date(),
                        type: "time",
                        timeInterval: 5,
                        title: "5 second notification",
                        body: "You can write more in here!")
                }
                
                Spacer()
                
                // SignUp
                VStack(spacing: 10){
                    Text("Don't have an account?")
                        .modifier(CustomTextM(fontName: "Oxygen-Regular", fontSize: 18, fontColor: Color.black))
                    Button(action: {
                        self.selection = 1
                    }){
                        Text("Register")
                            .modifier(CustomTextM(fontName: "Oxygen-Bold", fontSize: 18, fontColor: Color.yellow))
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal,30)
            .padding(.vertical, 25)
            .onAppear {
                Auth.auth().addStateDidChangeListener{auth, user in
                    if user != nil {
                        userLoggedIn.toggle()
                    }
                }
                
                setupNotifications()
            }
            
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    
//    func login(){
        //            Auth.auth().signIn(withEmail: email, password: password){result, error in
        //                if error != nil {
        //                    showingAlert = true
        //                    msg = error!.localizedDescription
        //                } else {
        //                    self.selection = 2
        //                }
        //            }
        //        }
    
        
        func login(){
            
            Auth.auth().signIn(withEmail: email, password: password){result, error in
                if error != nil {
                    showingAlert = true
                    msg = error!.localizedDescription
                } else {
                    
                    let ref = Firestore.firestore().collection("UserData")
                    ref.whereField("Country", isEqualTo: "").whereField("Difficulty", isEqualTo: "").whereField("Language", isEqualTo: "").getDocuments { (querySnapshot, error) in
                        if error != nil {
                            // Handle error
                        } else {
                            if !querySnapshot!.isEmpty {
                                self.selection = 2
                            } else {
                                self.selection = 3
                            }
                        }
                    }
                    
                    
                }
                
                
            }
        }
    
    
    func setupNotifications() {
        notificationController.askPermission()
        let currentDate = Date()
        let time = Calendar.current.date(byAdding: .second, value: 60, to: currentDate)!

        // Call the sendNotification method with the appropriate parameters
        notificationController.sendNotification(date: time, type: "date", title: "Your Notification Title", body: "Your Notification Body")

        // For repeating every 5 minutes, you can use a time-based trigger with a 5-minute interval
        let repeatingTime = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        notificationController.sendNotification(date: currentDate, type: "time", timeInterval: 60, title: "Repeating Notification Title", body: "Repeating Notification Body")
        }
    
    
        
    }

    
    struct Login_Previews: PreviewProvider {
        static var previews: some View {
            Login()
        }
    }
    

