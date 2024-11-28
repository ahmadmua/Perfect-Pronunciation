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
                            let storedIPs = data?["IP"] as? [String] ?? [] // Assume IP is a list

                            getCurrentIP { currentIP in
                                if !storedIPs.contains(currentIP) {
                                    // New IP detected, send verification email
                                    sendVerificationEmail(to: user.email ?? "", userId: user.uid, currentIP: currentIP) { success in
                                        DispatchQueue.main.async {
                                            if success {
                                                self.msg = "New IP detected. A verification email has been sent. Please verify to proceed."
                                                self.showingAlert = true
                                            } else {
                                                self.msg = "Failed to send verification email. Please try again."
                                                self.showingAlert = true
                                            }
                                        }
                                    }
                                } else {
                                    // IP matches, proceed with login
                                    proceedWithLogin(data: data, user: user)
                                }
                            }
                        } else {
                            // New user, initialize data
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




    func proceedWithLogin(data: [String: Any]?, user: User) {
        let country = data?["Country"] as? String ?? ""
        let difficulty = data?["Difficulty"] as? String ?? ""

        if country.isEmpty || difficulty.isEmpty {
            self.selection = 2
        } else {
            self.selection = 3
        }

        userData.setCountry(country: country)
        userData.setDifficulty(difficulty: difficulty)
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
    
    func sendVerificationEmail(to email: String, userId: String, currentIP: String, completion: @escaping (Bool) -> Void) {
        let verificationLink = "https://us-central1-perfectpronunciation-3aeeb.cloudfunctions.net/verifyIP?uid=\(userId)&ip=\(currentIP)"
        let subject = "New Login Attempt from a Different IP Address"
        let body = """
        We've detected a login attempt from a new location.
        If this was you, please verify your identity by clicking the link below:
        \(verificationLink)

        If you did not attempt to log in, we recommend securing your account.
        """

        let mailerSendAPIKey = "mlsn.13534ebe78e89d69613cbe6ad60d9f5ed9d5269ab96b96a7579de9347578fdb1" // Replace with your API key
        let payload: [String: Any] = [
            "from": ["email": "MS_Fm0USK@trial-v69oxl5rr5xg785k.mlsender.net", "name": "Perfect Pronunciation"],
            "to": [["email": email]],
            "subject": subject,
            "text": body
        ]

        guard let url = URL(string: "https://api.mailersend.com/v1/email") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(mailerSendAPIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 202 {
                    completion(true) // Email sent successfully
                } else {
                    print("Failed with status code: \(httpResponse.statusCode)")
                    if let responseData = data {
                        print("Response: \(String(data: responseData, encoding: .utf8) ?? "No data")")
                    }
                    completion(false)
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }.resume()
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
