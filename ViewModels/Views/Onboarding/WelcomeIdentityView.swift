import SwiftUI

struct WelcomeIdentityView: View {
    @AppStorage("userID") private var userID: String = ""
    @State private var navigateToNext = false
    @State private var showID = false
    @State private var showContinue = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                // Header section
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                        .foregroundColor(Color("BrandBlue"))

                    Text("Your Anonymous ID")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))

                    Text("This secure ID helps us privately track your check-ins and trends. No login required — just tap to generate.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Show ID block
                if showID && !userID.isEmpty {
                    VStack(spacing: 6) {
                        Text("✅ Your ID:")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text("\(userID.prefix(8))...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("BrandBlue"))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Generate button
                if !showID {
                    Button(action: {
                        userID = UUID().uuidString
                        showID = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showContinue = true
                        }
                    }) {
                        Text("Generate My ID")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("BrandBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .frame(maxWidth: 240)
                }

                // Continue button
                if showContinue {
                    NavigationLink(destination: AddLifesaversView(), isActive: $navigateToNext) {
                        EmptyView()
                    }

                    Button(action: {
                        navigateToNext = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("BrandBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .frame(maxWidth: 240)
                    .transition(.opacity)
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeIdentityView()
}
