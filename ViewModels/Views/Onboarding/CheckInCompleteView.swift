import SwiftUI

struct CheckInCompleteView: View {
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(Color("BrandBlue"))

                Text("You're All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BrandBlue"))
                    .multilineTextAlignment(.center)

                Text("Thanks for setting your baseline. You're off to a great start — let’s head to your dashboard.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                Spacer()

                NavigationLink(destination: DashboardView(), isActive: $navigate) {
                    EmptyView()
                }

                Button(action: {
                    navigate = true
                }) {
                    Text("Continue to Dashboard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("BrandBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .frame(maxWidth: 240)

                Spacer(minLength: 30)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    CheckInCompleteView()
}
