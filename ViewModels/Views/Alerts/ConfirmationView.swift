import SwiftUI

struct ConfirmationView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Text("✅ Check-In Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BrandBlue"))
                    .multilineTextAlignment(.center)

                Text("Thanks for checking in. You're doing great — every entry helps build insight and safety.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                NavigationLink(destination: DashboardView()) {
                    Text("Back to Dashboard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("BrandBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .frame(maxWidth: 240)

                Spacer(minLength: 40)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ConfirmationView()
}
