import SwiftUI
import Firebase
import FirebaseAuth

struct UpdateInfo: View {
    
    @State private var selection: Int? = nil
    @State var currentPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    @State private var userLoggedIn = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        
        VStack {
            
            NavigationLink(destination: Settings(), tag: 1, selection: self.$selection){}
            
            Text("Update Information")
                .fontWeight(.bold)
                .font(Font.system(size: 50))
                .foregroundColor(Color.yellow)
                .padding(.bottom, 100)
            
            VStack(spacing: 10) {
                SecureField("Current Password", text: $currentPassword)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                SecureField("New Password", text: $newPassword)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                SecureField("Confirm New Password", text: $confirmPassword)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                updatePassword()
            }) {
                Text("Update")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            
            .alert(self.alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func updatePassword() {
        guard let user = Auth.auth().currentUser else {
            alertMessage = "No user is currently signed in."
            showingAlert = true
            return
        }

        // Check if new password and confirm password match
        guard newPassword == confirmPassword else {
            alertMessage = "New password and confirm password do not match."
            showingAlert = true
            return
        }

        // Check if the entered current password is correct
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
        user.reauthenticate(with: credential) { (_, error) in
            if let error = error {
                alertMessage = "Error reauthenticating user: \(error.localizedDescription)"
                showingAlert = true
                return
            }

            // Reauthentication successful, update the password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    alertMessage = "Error updating password: \(error.localizedDescription)"
                    showingAlert = true
                } else {
                    alertMessage = "Password updated successfully."
                    showingAlert = true
                }
            }
        }
    }
}

struct UpdateInfo_Previews: PreviewProvider {
    static var previews: some View {
        UpdateInfo()
    }
}
