import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userProfileStore: UserProfileStore
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var lifesaverStore: LifesaverStore
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("notificationHour") var notificationHour: Int = 8
    @AppStorage("notificationMinute") var notificationMinute: Int = 0
    @AppStorage("userID") var userID: String = ""
    @AppStorage("hasSeenDashboard") var hasSeenDashboard: Bool = false
    @AppStorage("hasCompletedBaseline") var hasCompletedBaseline: Bool = false

    @State private var showResetAlert = false
    @State private var showCopyConfirmation = false
    @State private var navigateToBaseline = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Baseline
                    Card {
                        SectionHeader(title: "🧭 Your Baseline")
                        VStack(alignment: .leading, spacing: 6) {
                            if let profile = userProfileStore.profile {
                                Text("Mood: \(profile.baselineMood)")
                                Text("Energy: \(profile.baselineEnergy)")
                                Text("Sleep: \(profile.baselineSleep)")
                                Text("Appetite: \(profile.baselineAppetite)")
                                Text("Anxiety: \(profile.baselineAnxiety)")

                                if let note = profile.personalNote, !note.isEmpty {
                                    Text("Note: \(note)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.top, 6)
                                }

                                Button("Reset Baseline") {
                                    showResetAlert = true
                                }
                                .foregroundColor(.red)
                                .padding(.top, 6)
                            } else {
                                Text("Baseline not set yet.")
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Notifications
                    Card {
                        SectionHeader(title: "🔔 Notifications")
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Daily Check-In Reminder", isOn: $notificationsEnabled)
                                .onChange(of: notificationsEnabled) { newValue in
                                    if newValue {
                                        NotificationManager.shared.requestAuthorization { granted in
                                            if granted {
                                                NotificationManager.shared.scheduleDailyReminder(
                                                    hour: notificationHour,
                                                    minute: notificationMinute
                                                )
                                            }
                                        }
                                    } else {
                                        NotificationManager.shared.cancelDailyReminder()
                                    }
                                }

                            if notificationsEnabled {
                                DatePicker("Reminder Time", selection: Binding(
                                    get: {
                                        Calendar.current.date(from: DateComponents(
                                            hour: notificationHour,
                                            minute: notificationMinute
                                        )) ?? Date()
                                    },
                                    set: { newDate in
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                        notificationHour = components.hour ?? 8
                                        notificationMinute = components.minute ?? 0
                                        NotificationManager.shared.scheduleDailyReminder(
                                            hour: notificationHour,
                                            minute: notificationMinute
                                        )
                                    }
                                ), displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // App Info
                    Card {
                        SectionHeader(title: "📱 App Info")
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Version \(Bundle.main.appVersion)")
                                .foregroundColor(.gray)

                            if !userID.isEmpty {
                                Text("User ID: \(userID.prefix(8))...")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Button("Copy User ID") {
                                    UIPasteboard.general.string = userID
                                    showCopyConfirmation = true
                                }
                                .font(.caption)
                                .foregroundColor(Color("BrandBlue"))
                            }

                            if let url = URL(string: "mailto:support@yourapp.com") {
                                Link("Send Feedback", destination: url)
                                    .foregroundColor(Color("BrandBlue"))
                            }

                            Text("🪖 Built with Veterans in Mind")
                                .font(.footnote)
                                .foregroundColor(Color("BrandBlue"))
                                .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                    }

                    // 🧪 TEMP: Developer Reset Button
                    Card {
                        SectionHeader(title: "🧪 Developer Tools (Temp)")
                        Button("Reset Entire App") {
                            userID = ""
                            notificationsEnabled = false
                            hasCompletedBaseline = false
                            hasSeenDashboard = false
                            notificationHour = 8
                            notificationMinute = 0

                            userProfileStore.clearProfile()
                            checkInStore.clearAll()
                            lifesaverStore.clear()
                        }
                        .foregroundColor(.red)
                    }

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 40)

                NavigationLink(destination: BaselineSurveyView(), isActive: $navigateToBaseline) {
                    EmptyView()
                }
            }
            .alert("Reset Baseline?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    userProfileStore.profile = nil
                    navigateToBaseline = true
                }
            }
            .alert("User ID copied!", isPresented: $showCopyConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// MARK: - App Version Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
}
