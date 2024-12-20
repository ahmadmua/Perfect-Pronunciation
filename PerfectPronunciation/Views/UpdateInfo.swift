import SwiftUI
import Firebase
import FirebaseAuth

struct UpdateInfo: View {
    
    @State private var selection: Int? = nil
    @State var email: String = Auth.auth().currentUser?.email ?? ""
    @State var currentPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            NavigationLink(destination: Settings(), tag: 1, selection: self.$selection) {}
            NavigationLink(destination: Login(), tag: 2, selection: self.$selection) {}
            
            Text("Update Pass")
                .fontWeight(.bold)
                .font(Font.system(size: 50))
                .foregroundColor(Color.yellow)
                .padding(.bottom, 100)
            
            // Email Field (Uneditable)
            TextField("Email", text: $email)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5).frame(height: 45))
                .multilineTextAlignment(.center)
                .disabled(true) // Greyed out and uneditable
            
            // Current Password Field
            SecureField("Current Password", text: $currentPassword)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                .multilineTextAlignment(.center)
            
            // New Password Field
            SecureField("New Password", text: $newPassword)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                .multilineTextAlignment(.center)
            
            // Confirm New Password Field
            SecureField("Confirm New Password", text: $confirmPassword)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.5).frame(height: 45))
                .multilineTextAlignment(.center)
            
            // Update Button
            Button(action: {
                if validatePassword(newPassword) {
                    updatePassword()
                }
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
        .padding(.horizontal, 30)
        .padding(.vertical, 25)
    }
    
    func validatePassword(_ password: String) -> Bool {
        if password.count < 8 {
            alertMessage = "Password must be at least 8 characters long."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isUppercase }) {
            alertMessage = "Password must contain at least one uppercase letter."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isLowercase }) {
            alertMessage = "Password must contain at least one lowercase letter."
            showingAlert = true
            return false
        }
        if !password.contains(where: { $0.isNumber }) {
            alertMessage = "Password must contain at least one number."
            showingAlert = true
            return false
        }
        if !password.contains(where: { "!@#$%^&*(),.?\":{}|<>".contains($0) }) {
            alertMessage = "Password must contain at least one special character."
            showingAlert = true
            return false
        }
        return true
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
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { (_, error) in
            if let error = error {
                alertMessage = "Current Password Incorrect"
                showingAlert = true
                return
            }

            // Reauthentication successful, update the password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    alertMessage = "Error updating password: \(error.localizedDescription)"
                    showingAlert = true
                } else {
                    alertMessage = "Password updated successfully. Please re-login."
                    showingAlert = true
                    self.selection = 2
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
