import SwiftUI

struct HighRiskSupportView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("You Are Not Alone")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("BrandBlue"))

                        Text("We noticed signs that you may be going through something really difficult. We're here to support you — right now.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }

                    // Support Options
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "💬 Talk to Someone Now")

                        Link("📱 Text HELLO to 741741 (Crisis Text Line)", destination: URL(string: "https://www.crisistextline.org")!)
                        Link("📞 Call 988 (Suicide & Crisis Lifeline)", destination: URL(string: "tel://988")!)
                        Link("🌐 Visit 988lifeline.org", destination: URL(string: "https://988lifeline.org")!)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Button
                    Button(action: {}) {
                        NavigationLink(destination: DashboardView()) {
                            Text("Return to Dashboard")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("BrandBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
