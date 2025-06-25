import SwiftUI

@main
struct MentalHealthApp: App {
    @StateObject var checkInStore = CheckInStore()
    @StateObject var userProfileStore = UserProfileStore()
    @StateObject var lifesaverStore: LifesaverStore
    @StateObject var alertManager: AlertManager

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
                    let monitor = MissedCheckInMonitor(
                        checkInStore: checkInStore,
                        alertManager: alertManager,
                        userProfile: userProfileStore.profile
                    )
                    monitor.evaluateMissedCheckIns()
                }
        }
    }
}
