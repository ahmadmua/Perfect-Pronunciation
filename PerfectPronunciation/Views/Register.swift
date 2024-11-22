import SwiftUI
import Firebase
import FirebaseAuth

struct Register: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State private var selection: Int? = nil
    @State private var userLoggedIn = false
    @State private var showingAlert = false
    @State private var msg = ""
    @State private var userData = UserData()

    var body: some View {
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
                }
            }
            
            // SignUp
            Button(action: {
                if validatePassword(password) {
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
            
            // SignUp
            VStack(spacing: 10) {
                Text("Already have an account?")
                    .modifier(CustomTextM(fontName: "Oxygen-Regular", fontSize: 18, fontColor: Color.black))
                Button(action: {
                    self.selection = 1
                }) {
                    Text("Login")
                        .modifier(CustomTextM(fontName: "Oxygen-Bold", fontSize: 18, fontColor: Color.yellow))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 30)
        .padding(.vertical, 25)
    }

    func validatePassword(_ password: String) -> Bool {
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
            if error != nil {
                showingAlert = true
                msg = error!.localizedDescription
            } else {
                Firestore.firestore().collection("UserData").document(Auth.auth().currentUser!.uid).setData(
                    [
                        "Country": "",
                        "Difficulty": "",
                        "Currency": 0.0,
                        "Experience": 0.0,
                        "ExperienceLevel": 1.0,
                        "WeeklyChallengeComplete": 0.0,
                        "LessonsCompleted": [
                            "Conversation": false,
                            "Numbers": false,
                            "Directions": false,
                            "Food1": false,
                            "Food2": false
                        ],
                        "LessonQuestions": [
                            "Conversation": [
                                "Difficulty": "",
                                "Questions": ""
                            ],
                            "Numbers": [
                                "Difficulty": "",
                                "Questions": ""
                            ],
                            "Directions": [
                                "Difficulty": "",
                                "Questions": ""
                            ],
                            "Food1": [
                                "Difficulty": "",
                                "Questions": ""
                            ],
                            "Food2": [
                                "Difficulty": "",
                                "Questions": ""
                            ]
                        ],
                        "Achievements": [
                            "Achievement 1": false
                        ],
                        "Items": [
                            "TimeIncrease": false
                        ],
                        "Username": email.components(separatedBy: "@").first ?? "",
                    ]
                )
                self.selection = 1
            }
        }
    }
}
