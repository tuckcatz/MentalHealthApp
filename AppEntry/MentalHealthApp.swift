import SwiftUI

@main
struct MentalHealthApp: App {
    @StateObject var checkInStore = CheckInStore()
    @StateObject var userProfileStore = UserProfileStore()
    @StateObject var lifesaverStore: LifesaverStore
    @StateObject var alertManager: AlertManager

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let store = LifesaverStore()
        _lifesaverStore = StateObject(wrappedValue: store)
        _alertManager = StateObject(wrappedValue: AlertManager(lifesaverStore: store))
    }

    var body: some Scene {
        WindowGroup {
            WelcomeLogoView()
                .environmentObject(checkInStore)
                .environmentObject(userProfileStore)
                .environmentObject(lifesaverStore)
                .environmentObject(alertManager)
                .onAppear {
                    // Evaluate absence logic once per launch
                    let monitor = MissedCheckInMonitor(
                        checkInStore: checkInStore,
                        alertManager: alertManager,
                        userProfile: userProfileStore.profile
                    )
                    monitor.evaluateMissedCheckIns()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Ensure we re-evaluate check-in status when app resumes
                    checkInStore.refreshCheckInStatus()
                }
        }
    }
}
