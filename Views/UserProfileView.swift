import SwiftUI
import CoreLocation

struct UserProfileView: View {
    @Binding var user: User
    @Environment(\.presentationMode) var presentationMode
    @State private var newService: String = ""
    @State private var editingServiceIndex: Int? = nil
    @State private var editedService: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $user.name)
                    TextField("Profile Image URL", text: Binding(
                        get: { user.profileImageURL ?? "" },
                        set: { user.profileImageURL = $0.isEmpty ? nil : $0 }
                    ))
                }
                Section(header: Text("Services You Provide")) {
                    ForEach(user.categories.indices, id: \.self) { idx in
                        HStack {
                            if editingServiceIndex == idx {
                                TextField("Service", text: $editedService)
                                Button("Save") {
                                    user.categories[idx] = editedService
                                    editingServiceIndex = nil
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            } else {
                                Text(user.categories[idx])
                                Spacer()
                                Button(action: {
                                    editedService = user.categories[idx]
                                    editingServiceIndex = idx
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    user.categories.remove(at: idx)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    HStack {
                        TextField("Add new service", text: $newService)
                        Button(action: {
                            let trimmed = newService.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            user.categories.append(trimmed)
                            newService = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Preview
struct UserProfileView_Previews: PreviewProvider {
    @State static var user = User(
        name: "Jane Doe",
        email: "jane@example.com",
        isProvider: true,
        categories: ["Plumbing", "Electrical"]
    )
    static var previews: some View {
        UserProfileView(user: $user)
    }
} 