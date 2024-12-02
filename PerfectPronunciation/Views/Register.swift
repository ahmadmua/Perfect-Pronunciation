import SwiftUI
import Firebase
import FirebaseAuth

struct Register: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State private var selection: Int? = nil
    @State private var userLoggedIn = false
    @State private var showingAlert = false
    @State private var msg = ""
    @State private var userData = UserData()
    
    // Placeholder for the IP address
    @State private var userIP: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink(destination: Login(), tag: 1, selection: self.$selection) {}
                
                Spacer()
                
                Text("REGISTER")
                    .fontWeight(.bold)
                    .font(Font.system(size: 50))
                    .foregroundColor(Color.yellow)
                    .padding(.bottom, 100)
                
                // Form
                VStack(spacing: 25) {
                    TextField("Email", text: $email)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 10) {
                        SecureField("Password", text: $password)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                            .multilineTextAlignment(.center)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(action: {
                    if validatePassword(password, confirmPassword: confirmPassword) {
                        userData.setEmail(registeredEmail: email)
                        userData.setPass(registeredPassword: password)
                        register()
                    }
                }) {
                    Text("Sign Up")
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
            }
            .onAppear {
                fetchUserIP()
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal, 30)
            .padding(.vertical, 25)
        }
    }
    
    
    func fetchUserIP() {
        if let url = URL(string: "https://api.ipify.org?format=json") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    if let json = try? JSONDecoder().decode([String: String].self, from: data),
                       let ip = json["ip"] {
                        DispatchQueue.main.async {
                            self.userIP = ip
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func validatePassword(_ password: String, confirmPassword: String) -> Bool {
        if password != confirmPassword {
            msg = "Passwords do not match."
            showingAlert = true
            return false
        }
        
        if password.count < 8 {
            msg = "Password must be at least 8 characters long."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isUppercase }) {
            msg = "Password must contain at least one uppercase letter."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isLowercase }) {
            msg = "Password must contain at least one lowercase letter."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isNumber }) {
            msg = "Password must contain at least one number."
            showingAlert = true
            return false
        }
        if !password.contains(where: { "!@#$%^&*(),.?\":{}|<>".contains($0) }) {
            msg = "Password must contain at least one special character."
            showingAlert = true
            return false
        }
        return true
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                showingAlert = true
                msg = error.localizedDescription
                return
            }
            
            // Send email verification after successful registration
            sendVerificationEmail()
            
            // Add user data to Firestore, including the captured IP address
            Firestore.firestore().collection("UserData").document(Auth.auth().currentUser!.uid).setData(
                ["Country": "",
                 "Difficulty": "",
                 "Currency": 0.0,
                 "Experience": 0.0,
                 "TotalExperience": 0.0,
                 "ExperienceLevel": 1.0,
                 "League" : "",
                 "WeeklyChallengeComplete": 0.0,
                 "LessonsCompleted": [
                    "Conversation" : false,
                    "Numbers" : false,
                    "Directions" : false,
                    "Food1" : false,
                    "Food2" : false,
                    "Christmas" : false
                    
                 ],
                 "LessonQuestions": [
                    "Conversation" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ],
                    "Numbers" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ],
                    "Directions" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ],
                    "Food1" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ],
                    "Food2" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ],
                    "Christmas" : [
                        "Difficulty" : "",
                        "Questions" : ""
                    ]
                 ],
                 "Achievements": [
                    "Achievement 1" : false,
                    "Achievement 2" : false,
                    "Achievement 3" : false,
                    "Achievement 4" : false,
                    "Achievement 5" : false,
                 ],
                 "AchievementsCheck": [
                    "Achievement 1" : false,
                    "Achievement 2" : false,
                    "Achievement 3" : false,
                    "Achievement 4" : false,
                    "Achievement 5" : false
                 ],
                 "Items": [
                    "TimeIncrease" : false,
                    "ChristmasLesson" : false,
                    "LevelBoost" : false,//dont really need this one as the level up happens right on the store page
                    "WeeklyChallengeWager" : false
                 ],
                 "Username" : email.components(separatedBy: "@").first ?? "",
                    "IP": [userIP] // Store the user's IP address here
                ]
            )
            
            // Show the login screen after successful registration
            self.selection = 1
        }
    }
    
    func sendVerificationEmail() {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    showingAlert = true
                    msg = "Error sending verification email: \(error.localizedDescription)"
                    return
                }
                showingAlert = true
                msg = "Please check your inbox to verify your email address."
            }
        }
    }
    
    
    
}
    


//struct Register_Previews: PreviewProvider {
//    static var previews: some View {
//        Register()
//    }
//}
