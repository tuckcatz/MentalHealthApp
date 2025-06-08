import SwiftUI

struct OnboardingResumeView: View {
    @AppStorage("userID") var userID: String = ""
    @AppStorage("hasAddedLifesavers") var hasAddedLifesavers: Bool = false
    @AppStorage("hasCompletedBaseline") var hasCompletedBaseline: Bool = false
    @EnvironmentObject var lifesaverStore: LifesaverStore

    @State private var resume = false
    @State private var restart = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BrandBlue"))

                Text("Looks like you started setting things up but didn’t finish. Want to pick up where you left off or start over?")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Spacer()

                // Navigation logic based on progress
                NavigationLink(destination: resumeDestination(), isActive: $resume) {
                    EmptyView()
                }

                NavigationLink(destination: WelcomeIntroView(), isActive: $restart) {
                    EmptyView()
                }

                VStack(spacing: 16) {
                    Button(action: {
                        resume = true
                    }) {
                        Text("Where I Left Off")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("BrandBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .frame(maxWidth: 240)

                    Button(action: {
                        userID = ""
                        hasAddedLifesavers = false
                        hasCompletedBaseline = false
                        restart = true
                    }) {
                        Text("Start Over")
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

                Spacer(minLength: 40)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Resume Routing Logic

    func resumeDestination() -> some View {
        if !hasAddedLifesavers || lifesaverStore.contacts.isEmpty {
            return AnyView(AddLifesaversView())
        } else if !hasCompletedBaseline {
            return AnyView(BaselineSurveyView())
        } else {
            return AnyView(DashboardView())
        }
    }
}

#Preview {
    OnboardingResumeView()
        .environmentObject(LifesaverStore())
}
