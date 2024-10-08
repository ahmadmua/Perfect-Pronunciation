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
    //let openAIService = OpenAIService()
    
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
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
        
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                showingAlert = true
                msg = "Login Information Incorrect"
            } else if let user = result?.user {
                let ref = Firestore.firestore().collection("UserData").document(user.uid)
                
                ref.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let country = data?["Country"] as? String ?? ""
                        let difficulty = data?["Difficulty"] as? String ?? ""
                        
                        if country.isEmpty || difficulty.isEmpty {
                            // Redirect to Country and Difficulty selection screen if either is empty
                            self.selection = 2
                        } else {
                            // Redirect to Homepage if both fields are filled
                            self.selection = 3
                        }
                        
                        // Cache the data to prevent re-selecting country and difficulty on re-login
                        userData.setCountry(country: country)
                        userData.setDifficulty(difficulty: difficulty)
                        
                    } else {
                        // Handle document does not exist scenario
                        self.selection = 2 // Go to country and difficulty setup screen
                    }
                }
            }
        }
    }

    

        
    }

    
    struct Login_Previews: PreviewProvider {
        static var previews: some View {
            Login()
        }
    }
    

