import SwiftUI

struct TutorialSliderView: View {
    @State private var currentIndex = 0
    @State private var navigateToNext = false

    let slides: [TutorialSlide] = [
        TutorialSlide(title: "Asking for help is the hardest part.", body: "This app is designed to do many things, but at its core, it's built to help you ask for help. Here's how..."),
        TutorialSlide(title: "Your anonymous ID.", body: "You'll receive a unique ID to anonymize your data and protect your privacy. We'll use it to track your check-ins, baseline info, and trends."),
        TutorialSlide(title: "Add your LifeSavers.", body: "These are trusted contacts. You can share their phone or email. If we detect high risk, we'll notify them to check in with you."),
        TutorialSlide(title: "Baseline check-in comes first.", body: "Your starting point. All future check-ins and data compare to it. Reset anytime in Settings."),
        TutorialSlide(title: "Daily check-ins matter.", body: "You'll do a quick check-in each day. You can customize reminder times in Settings."),
        TutorialSlide(title: "We detect risk and act.", body: "If we detect concern in your data, we'll provide support resources and alert your LifeSavers if needed."),
        TutorialSlide(title: "Explore your resources.", body: "Find articles, mindfulness tools, and view your mood trends over time."),
        TutorialSlide(title: "Export for therapy or reflection.", body: "If you're working with a therapist, you can export your anonymized data from Settings."),
        TutorialSlide(title: "Ready to go?", body: "Let's get started by creating your ID, adding your LifeSavers and setting your baseline.")
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
