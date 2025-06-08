import SwiftUI

struct EditLifesaversView: View {
    @EnvironmentObject var lifesaverStore: LifesaverStore
    @AppStorage("hasAddedLifesavers") var hasAddedLifesavers: Bool = false

    @State private var nameInput: String = ""
    @State private var phoneInput: String = ""
    @State private var emailInput: String = ""
    @State private var editingContactID: UUID?
    @State private var showLastContactAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Trusted Contacts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BrandBlue"))
                    .padding(.top)

                Text("These are the people we’ll reach out to if your check-ins signal concern.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Input Form
                VStack(spacing: 12) {
                    TextField("Name (required)", text: $nameInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Phone Number (required)", text: $phoneInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)

                    TextField("Email (optional)", text: $emailInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: handleSave) {
                        Text(editingContactID == nil ? "Add Contact" : "Update Contact")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isInputValid ? Color("BrandBlue") : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!isInputValid)
                    .frame(maxWidth: 220)
                }
                .padding(.horizontal)

                if lifesaverStore.contacts.isEmpty {
                    Text("You must have at least one contact listed.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 6)
                }

                // Contact List
                List {
                    Section {
                        Text("Tap to edit. Swipe to delete.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    ForEach(lifesaverStore.contacts) { contact in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.contactMethod)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            loadContactForEditing(contact)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if lifesaverStore.contacts.count == 1 {
                                    showLastContactAlert = true
                                } else {
                                    delete(contact)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)

                Spacer(minLength: 20)
            }
            .padding()
            .navigationTitle("Edit LifeSavers")
            .alert("Must Keep at Least One LifeSaver", isPresented: $showLastContactAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("To ensure your safety, you must always have at least one trusted contact. You can tap a contact to update their information.")
            }
        }
    }

    // MARK: - Validation
    private var isInputValid: Bool {
        !nameInput.isEmpty && phoneInput.filter(\.isNumber).count == 10
    }

    // MARK: - Actions
    private func handleSave() {
        guard isInputValid else { return }

        let method = "Phone: \(phoneInput)" + (emailInput.isEmpty ? "" : " | Email: \(emailInput)")

        if let editingID = editingContactID,
           let index = lifesaverStore.contacts.firstIndex(where: { $0.id == editingID }) {
            lifesaverStore.contacts[index] = TrustedContact(id: editingID, name: nameInput, contactMethod: method)
        } else {
            lifesaverStore.add(TrustedContact(name: nameInput, contactMethod: method))
        }

        clearForm()
        hideKeyboard()
        hasAddedLifesavers = true
    }

    private func delete(_ contact: TrustedContact) {
        if let index = lifesaverStore.contacts.firstIndex(where: { $0.id == contact.id }) {
            lifesaverStore.contacts.remove(at: index)
            lifesaverStore.save()
        }
    }

    private func loadContactForEditing(_ contact: TrustedContact) {
        nameInput = contact.name
        phoneInput = contact.contactMethod
            .components(separatedBy: " | ")
            .first?
            .replacingOccurrences(of: "Phone: ", with: "") ?? ""
        emailInput = contact.contactMethod.contains("Email:") ?
            contact.contactMethod.components(separatedBy: "Email: ").last ?? "" : ""
        editingContactID = contact.id
    }

    private func clearForm() {
        nameInput = ""
        phoneInput = ""
        emailInput = ""
        editingContactID = nil
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
