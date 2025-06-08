import SwiftUI

struct WelcomeIntroView: View {
    @State private var navigateToTutorial = false
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                Text("Welcome to CheckIn")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("BrandBlue"))

                // Intro copy
                Text("""
Hi, I’m Jeremy — creator of CheckIn, a mental health tool for reaching out when you're not sure how.

I've found it nearly impossible to ask for help.  

Maybe it’s ego or pride, maybe it’s the way I was raised or how I feel I’m supposed to act for society’s sake… who knows.

I created this app because I know I can’t be the only one that feels this way. 

I hope you find it useful.
""")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)

                // CTA Button
                Button(action: {
                    navigateToTutorial = true
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

                // Hidden nav link
                NavigationLink(destination: TutorialSliderView(), isActive: $navigateToTutorial) {
                    EmptyView()
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .center) // 🔥 THIS CENTERS IT
            .opacity(showContent ? 1 : 0)
            .animation(.easeIn(duration: 1.2), value: showContent)
            .onAppear {
                showContent = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeIntroView()
}
