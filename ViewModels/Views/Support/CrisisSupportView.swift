import SwiftUI

struct CrisisSupportView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Get Help Now")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal)

                    // U.S. National Hotlines
                    Card {
                        SectionHeader(title: "📞 U.S. National Hotlines")

                        VStack(alignment: .leading, spacing: 10) {
                            Link("Call 988 – Suicide & Crisis Lifeline", destination: URL(string: "tel://988")!)
                                .foregroundColor(Color("BrandBlue"))

                            Link("Text HELLO to 741741 – Crisis Text Line", destination: URL(string: "https://www.crisistextline.org")!)
                                .foregroundColor(Color("BrandBlue"))
                        }
                    }

                    // Veterans Crisis Line
                    Card {
                        SectionHeader(title: "🇺🇸 Veterans Crisis Support")

                        VStack(alignment: .leading, spacing: 10) {
                            Link("Call 1-800-273-8255 (Press 1)", destination: URL(string: "tel://18002738255")!)
                                .foregroundColor(Color("BrandBlue"))

                            Link("Text 838255", destination: URL(string: "sms:838255")!)
                                .foregroundColor(Color("BrandBlue"))

                            Link("Visit VeteransCrisisLine.net", destination: URL(string: "https://www.veteranscrisisline.net")!)
                                .foregroundColor(Color("BrandBlue"))
                        }
                    }

                    // Global Support
                    Card {
                        SectionHeader(title: "🌍 Global Support")

                        Link("Befrienders Worldwide – International Crisis Help", destination: URL(string: "https://www.befrienders.org")!)
                            .foregroundColor(Color("BrandBlue"))
                    }

                    // Emergency Note
                    Card {
                        Text("🚨 If you're in danger or feeling unsafe, please dial 911 or go to the nearest emergency room.")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .navigationTitle("Crisis Support")
        }
    }
}

#Preview {
    CrisisSupportView()
}
