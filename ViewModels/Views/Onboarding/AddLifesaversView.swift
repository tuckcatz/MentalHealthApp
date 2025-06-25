import SwiftUI

struct AddLifesaversView: View {
    @EnvironmentObject var lifesaverStore: LifesaverStore
    @AppStorage("hasAddedLifesavers") var hasAddedLifesavers: Bool = false

    @State private var nameInput: String = ""
    @State private var phoneInput: String = ""
    @State private var identifierNote: String = ""
    @State private var navigateToNext = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer(minLength: 30)

                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundColor(Color("BrandBlue"))

                    Text("Add Your LifeSavers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .multilineTextAlignment(.center)

                    Text("These are trusted people you choose. If we detect high-risk patterns in your check-ins, we can let them know it's a good time to check in on you.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("You've added \(lifesaverStore.contacts.count) of 3 contacts.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Input fields
                VStack(spacing: 14) {
                    TextField("Name", text: $nameInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Phone Number", text: $phoneInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)

                    TextField("How will they recognize you?", text: $identifierNote)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        guard isInputValid else { return }

                        let contact = TrustedContact(
                            name: nameInput,
                            contactMethod: "Phone: \(phoneInput)",
                            identifierNote: identifierNote
                        )

                        lifesaverStore.add(contact)

                        nameInput = ""
                        phoneInput = ""
                        identifierNote = ""
                        hideKeyboard()
                    }) {
                        Text("Add Contact")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isInputValid ? Color("BrandBlue") : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: 200)
                    .disabled(!isInputValid)
                }
                .padding(.horizontal)

                // Contact list
                if !lifesaverStore.contacts.isEmpty {
                    List {
                        ForEach(lifesaverStore.contacts) { contact in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .fontWeight(.semibold)
                                Text(contact.contactMethod)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                if let note = contact.identifierNote {
                                    Text("Identifiable by: \(note)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: lifesaverStore.remove)
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Hidden NavLink
                NavigationLink(destination: BaselineSurveyView(), isActive: $navigateToNext) {
                    EmptyView()
                }

                // Finish button
                Button(action: {
                    hasAddedLifesavers = true
                    navigateToNext = true
                }) {
                    Text("Finish Setup")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(lifesaverStore.contacts.isEmpty ? Color.gray.opacity(0.5) : Color("BrandBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .frame(maxWidth: 240)
                .disabled(lifesaverStore.contacts.isEmpty)

                Spacer(minLength: 30)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }

    private var isInputValid: Bool {
        !nameInput.isEmpty &&
        phoneInput.filter(\.isNumber).count == 10 &&
        !identifierNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
