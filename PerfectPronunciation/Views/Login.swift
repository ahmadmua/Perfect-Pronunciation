import SwiftUI
import Firebase
import FirebaseAuth

struct Login: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State private var selection: Int? = nil
    @State private var userLoggedIn = false
    @State private var showingAlert = false
    @State private var msg = ""
    @State var userData = UserData()
    let notificationController = NotificationController()
    
    // For Forgot Password Popup
    @State private var showingForgotPasswordPopup = false
    @State private var resetEmail: String = ""
    @State private var showingResetAlert = false
    @State private var resetAlertMsg = ""
    @State private var passwordResetSuccessfully = false

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
                            email = userData.getEmail()
                            password = userData.getPass()
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
                    
                    Text("Forgot Password?")
                        .modifier(CustomTextM(fontName: "Oxygen-Regular", fontSize: 18, fontColor: Color.black))
                    Button(action: {
                        showingForgotPasswordPopup = true
                    }) {
                        Text("Reset Password")
                            .modifier(CustomTextM(fontName: "Oxygen-Bold", fontSize: 18, fontColor: Color.yellow))
                    }
                    .alert(isPresented: $showingResetAlert) {
                        Alert(title: Text("Password Reset"), message: Text(resetAlertMsg), dismissButton: .default(Text("OK")))
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
                
                notificationController.askPermission()
                notificationController.scheduleNotifications()
            }
            .sheet(isPresented: $showingForgotPasswordPopup) {
                ForgotPasswordView(resetEmail: $resetEmail, resetAlertMsg: $resetAlertMsg, showingResetAlert: $showingResetAlert, passwordResetSuccessfully: $passwordResetSuccessfully)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                showingAlert = true
                msg = "Login Information Incorrect"
            } else if let user = result?.user {
                if user.isEmailVerified {
                    let ref = Firestore.firestore().collection("UserData").document(user.uid)
                    
                    ref.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let country = data?["Country"] as? String ?? ""
                            let difficulty = data?["Difficulty"] as? String ?? ""
                            let storedIP = data?["IP"] as? String ?? ""

                            getCurrentIP { currentIP in
                                if currentIP != storedIP {
                                    self.msg = "Login attempt from a different IP address."
                                    self.showingAlert = true
                                } else {
                                    if country.isEmpty || difficulty.isEmpty {
                                        self.selection = 2
                                    } else {
                                        self.selection = 3
                                    }

                                    userData.setCountry(country: country)
                                    userData.setDifficulty(difficulty: difficulty)
                                }
                            }
                        } else {
                            self.selection = 2
                        }
                    }
                } else {
                    self.msg = "Please verify your email address before logging in."
                    self.showingAlert = true
                    
                    user.sendEmailVerification { error in
                        if let error = error {
                            self.msg = "Failed to send verification email: \(error.localizedDescription)"
                            self.showingAlert = true
                        } else {
                            self.msg = "Verification email sent. Please check your inbox."
                            self.showingAlert = true
                        }
                    }
                }
            }
        }
    }

    func getCurrentIP(completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.ipify.org?format=json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching IP: \(error.localizedDescription)")
                completion("")
            } else if let data = data, let json = try? JSONDecoder().decode([String: String].self, from: data), let ip = json["ip"] {
                completion(ip)
            } else {
                completion("")
            }
        }
        task.resume()
    }

}

struct ForgotPasswordView: View {
    
    @Binding var resetEmail: String
    @Binding var resetAlertMsg: String
    @Binding var showingResetAlert: Bool
    @Binding var passwordResetSuccessfully: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your email address to reset your password.")
                .font(.headline)
                .padding()
            
            TextField("Email", text: $resetEmail)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                .multilineTextAlignment(.center)
            
            Button(action: {
                resetPassword()
            }) {
                Text("Reset Password")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            
            if passwordResetSuccessfully {
                Text("Your password has been reset successfully. Please check your email.")
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .padding(.top, 20)
            }
        }
        .padding()
    }

    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            if let error = error {
                resetAlertMsg = "Error: \(error.localizedDescription)"
                passwordResetSuccessfully = false
            } else {
                resetAlertMsg = "Password reset link sent to your email."
                passwordResetSuccessfully = true
            }
            showingResetAlert = true
        }
    }
}
