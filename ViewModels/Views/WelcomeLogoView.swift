import SwiftUI

struct WelcomeLogoView: View {
    @AppStorage("userID") var userID: String = ""
    @AppStorage("hasAddedLifesavers") var hasAddedLifesavers: Bool = false
    @AppStorage("hasCompletedBaseline") var hasCompletedBaseline: Bool = false
    @AppStorage("checkInDeferredUntil") var checkInDeferredUntil: Date = .distantPast
    @AppStorage("shouldShowCheckIn") var shouldShowCheckIn: Bool = true

    @EnvironmentObject var checkInStore: CheckInStore

    @State private var animateLogo = false
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 16) {
                    if let logo = UIImage(named: "checkinlogo") {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .scaleEffect(animateLogo ? 1.0 : 0.92)
                            .opacity(animateLogo ? 1 : 0)
                            .animation(.easeOut(duration: 1.0), value: animateLogo)
                    }
                }

                NavigationLink(destination: nextScreen(), isActive: $navigate) {
                    EmptyView()
                }
            }
            .onAppear {
                animateLogo = true
                checkInStore.refreshCheckInStatus()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigate = true
                }
            }
        }
    }

    func nextScreen() -> some View {
        if userID.isEmpty {
            return AnyView(WelcomeIntroView())
        } else if !hasCompletedBaseline {
            return AnyView(OnboardingResumeView())
        } else if !checkInStore.hasCheckedInToday && Date() > checkInDeferredUntil && shouldShowCheckIn {
            return AnyView(HomeCheckInView())
        } else {
            return AnyView(DashboardView())
        }
    }
}
