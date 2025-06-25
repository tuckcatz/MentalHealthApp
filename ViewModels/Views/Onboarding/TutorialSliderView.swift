import SwiftUI

struct TutorialSliderView: View {
    @State private var currentIndex = 0
    @State private var navigateToNext = false

    let slides: [TutorialSlide] = [
        TutorialSlide(title: "Asking for help is the hardest part.", body: "CheckIn exists to make that easier. It watches for concerning patterns and alerts people you trust — so you're never truly alone, even when it feels like it. Here's how..."),
        TutorialSlide(title: "Your anonymous ID.", body: "You’ll receive a unique ID instead of a username. We don’t ask for your name or personal info — just your check-in data, trends, and how you’re doing."),
        TutorialSlide(title: "Add your LifeSavers.", body: "LifeSavers are people you trust. If you're in distress — or stop checking in for a while — we’ll send them a message encouraging them to check in on you."),
        TutorialSlide(title: "Your baseline matters.", body: "Before starting, you'll set a baseline: a snapshot of how you *typically* feel. We compare future check-ins to this to spot changes. You can reset it anytime."),
        TutorialSlide(title: "Check in daily — even briefly.", body: "A few quick taps each day help track how you’re doing over time. You’ll set a daily reminder to make it easy to stay consistent."),
        TutorialSlide(title: "We detect risk and act.", body: "If we see signs of distress, we’ll gently offer support resources. If it’s serious, we’ll automatically notify your LifeSavers to help you feel less alone."),
        TutorialSlide(title: "Explore helpful tools.", body: "You’ll find calming resources, mental health content, and trend charts to understand your mood, sleep, energy, and more — all in one place."),
        TutorialSlide(title: "Export your data anytime.", body: "If you're working with a therapist or doctor, you can securely export your anonymized check-in data from Settings to support your care."),
        TutorialSlide(title: "Let’s get started.", body: "We’ll walk you through creating your ID, adding your LifeSavers, and setting your baseline. You’re in control every step of the way.")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 16)

                TabView(selection: $currentIndex) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image("checkinlogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                                .padding(.top, 8)

                            Text(slides[index].title)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("BrandBlue"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Text(slides[index].body)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                                .padding(.horizontal)

                            if index == slides.count - 1 {
                                NavigationLink(destination: WelcomeIdentityView(), isActive: $navigateToNext) {
                                    EmptyView()
                                }

                                Button(action: {
                                    navigateToNext = true
                                }) {
                                    Text("Let's Start")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color("BrandBlue"))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                }
                                .frame(maxWidth: 240)
                                .padding(.top, 12)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)

                // Custom progress dots
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(index == currentIndex ? Color("BrandBlue") : Color.gray.opacity(0.3))
                    }
                }

                Spacer(minLength: 20)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct TutorialSlide {
    let title: String
    let body: String
}

#Preview {
    TutorialSliderView()
}
