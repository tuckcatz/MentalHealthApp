import SwiftUI

struct BaselineSurveyView: View {
    @State private var mood: Double = 5
    @State private var energy: Double = 5
    @State private var sleep: Double = 5
    @State private var anxiety: Double = 5
    @State private var appetite: Double = 5
    @State private var interest: Double = 5
    @State private var hopelessness: Double = 5

    @State private var feelsSafe: Bool = true
    @State private var hasHarmThoughts: Bool = false
    @State private var hasTrustedContact: Bool = true

    @State private var personalNote: String = ""
    @State private var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()

    @EnvironmentObject var userProfileStore: UserProfileStore
    @AppStorage("hasCompletedBaseline") var hasCompletedBaseline: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("notificationHour") var notificationHour: Int = 8
    @AppStorage("notificationMinute") var notificationMinute: Int = 0
    @State private var navigateToDashboard = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Set Your Baseline")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("BrandBlue"))

                    // Sliders
                    Group {
                        BaselineSlider(title: "Overall Mood", value: $mood)
                        BaselineSlider(title: "Energy Level", value: $energy)
                        BaselineSlider(title: "Sleep Quality", value: $sleep)
                        BaselineSlider(title: "Anxiety Level", value: $anxiety)
                        BaselineSlider(title: "Appetite Level", value: $appetite)
                        BaselineSlider(title: "Interest in Daily Activities", value: $interest)
                        BaselineSlider(title: "Feeling Hopeless or Stuck", value: $hopelessness)
                    }

                    // Safety & Support
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Safety & Support")
                            .font(.headline)

                        Toggle("Do you feel safe right now?", isOn: $feelsSafe)
                        Toggle("Have you had thoughts of harming yourself?", isOn: $hasHarmThoughts)
                        Toggle("Do you have someone you trust to talk to?", isOn: $hasTrustedContact)
                    }

                    // Note Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Anything you'd like us to know?")
                            .font(.headline)

                        TextEditor(text: $personalNote)
                            .frame(height: 100)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Reminder Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🕒 Daily Reminder Time")
                            .font(.headline)

                        Text("We'll remind you to check in at this time every day. You can change this later in Settings.")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                    }

                    // Submit Button
                    Button(action: handleSaveBaseline) {
                        Text("Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("BrandBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .frame(maxWidth: 240)

                    NavigationLink(destination: CheckInCompleteView(), isActive: $navigateToDashboard) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func handleSaveBaseline() {
        userProfileStore.setBaseline(
            mood: Int(mood),
            energy: Int(energy),
            sleep: Int(sleep),
            anxiety: Int(anxiety),
            appetite: Int(appetite),
            interest: Int(interest),
            hopelessness: Int(hopelessness),
            feelsSafe: feelsSafe,
            hasHarmThoughts: hasHarmThoughts,
            hasTrustedContact: hasTrustedContact,
            note: personalNote.isEmpty ? nil : personalNote
        )

        hasCompletedBaseline = true

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        notificationHour = components.hour ?? 8
        notificationMinute = components.minute ?? 0

        requestNotificationPermissionIfNeeded()
        navigateToDashboard = true
    }

    private func requestNotificationPermissionIfNeeded() {
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(
                        hour: notificationHour,
                        minute: notificationMinute
                    )
                }
            }
        }
    }
}

// MARK: - Custom Slider
struct BaselineSlider: View {
    var title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(Int(value))")
                .font(.headline)
            Slider(value: $value, in: 1...10, step: 1)
                .tint(Color("BrandBlue"))
        }
    }
}

#Preview {
    BaselineSurveyView()
        .environmentObject(UserProfileStore())
}
