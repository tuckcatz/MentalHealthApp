import SwiftUI

struct CrisisResourcesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Crisis Resources")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .multilineTextAlignment(.center)

                    Text("You are not alone. If you’re in crisis or feel unsafe, here are people you can talk to — right now.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    Divider()

                    VStack(alignment: .leading, spacing: 18) {
                        Text("📞 Suicide & Crisis Lifeline (USA)")
                            .font(.headline)
                            .foregroundColor(Color("BrandBlue"))

                        Link("Call 988", destination: URL(string: "tel://988")!)
                        Link("Visit 988lifeline.org", destination: URL(string: "https://988lifeline.org")!)

                        Divider()

                        Text("💬 Crisis Text Line")
                            .font(.headline)
                            .foregroundColor(Color("BrandBlue"))

                        Text("Text HELLO to 741741")
                        Link("crisistextline.org", destination: URL(string: "https://www.crisistextline.org")!)

                        Divider()

                        Text("🌍 International Resources")
                            .font(.headline)
                            .foregroundColor(Color("BrandBlue"))

                        Link("Befrienders Worldwide", destination: URL(string: "https://www.befrienders.org")!)
                        Link("Find a therapist (Psychology Today)", destination: URL(string: "https://www.psychologytoday.com")!)
                    }
                    .padding(.horizontal)

                    Spacer()

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
            }
        }
    }
}

#Preview {
    CrisisResourcesView()
}
