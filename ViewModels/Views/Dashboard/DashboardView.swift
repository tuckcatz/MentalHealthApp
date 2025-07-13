import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var userProfileStore: UserProfileStore
    @EnvironmentObject var alertManager: AlertManager

    @AppStorage("hasSeenDashboard") var hasSeenDashboard: Bool = false
    @AppStorage("hasSentAbsenceAlert") var hasSentAbsenceAlert: Bool = false
    @AppStorage("dismissedAbsencePromptAt5Days") var dismissedAbsencePromptAt5Days: Bool = false

    @State private var showWelcomeBack = false
    @State private var showAbsencePrompt = false
    @State private var missedDays = 0

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var recentMoodData: [CheckIn] {
        checkInStore.checkIns.suffix(7)
    }

    var averageMood: Int {
        let moods = recentMoodData.map { $0.moodRating }
        return moods.isEmpty ? 0 : moods.reduce(0, +) / moods.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeHeader

                    if showAbsencePrompt {
                        absencePrompt
                    }

                    moodTrendSection
                    checkInCard
                    insightCard

                    LazyVGrid(columns: columns, spacing: 16) {
                        DashboardCardLink(title: "Resources & Tools", icon: "books.vertical", destination: ResourcesAndLearningView())
                        DashboardCardLink(title: "Wellness Insights", icon: "waveform.path.ecg", destination: TrendAnalysisView())
                        DashboardCardLink(title: "Mood Calendar", icon: "calendar", destination: MoodCalendarView())
                        DashboardCardLink(title: "LifeSavers", icon: "person.3.fill", destination: EditLifesaversView())
                        DashboardCardLink(title: "Settings", icon: "gearshape", destination: SettingsView())
                        DashboardCardLink(title: "Get Help Now", icon: "exclamationmark.triangle", destination: CrisisSupportView(), iconColor: .red)
                    }
                    
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
                .padding(.top)
                .onAppear {
                    if !hasSeenDashboard {
                        showWelcomeBack = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            hasSeenDashboard = true
                        }
                    } else {
                        showWelcomeBack = true
                    }

                    // ✅ FIX: Skip all absence logic if user has never checked in
                    guard !checkInStore.checkIns.isEmpty else {
                        showAbsencePrompt = false
                        return
                    }

                    missedDays = checkInStore.missedCheckInDays()

                    if checkInStore.hasCheckedInToday {
                        showAbsencePrompt = false
                        return
                    }

                    if missedDays == 3 {
                        showAbsencePrompt = true
                    } else if missedDays == 5 && !dismissedAbsencePromptAt5Days {
                        showAbsencePrompt = true
                    }

                    if missedDays >= 5 && !hasSentAbsenceAlert {
                        NotificationManager.shared.sendPushAbsenceNotification()
                        alertManager.sendAbsenceAlert(missedDays: missedDays)
                        hasSentAbsenceAlert = true
                    } else if missedDays < 5 {
                        hasSentAbsenceAlert = false
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarBackButtonHidden(true)
        }
    }

    var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(showWelcomeBack ? "Welcome Back 👋" : "Welcome 👋")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color("BrandBlue"))

            Text("Glad you're here. Let's check in.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }

    var absencePrompt: some View {
        Card {
            VStack(spacing: 12) {
                Text(missedDays == 5
                     ? "You’ve missed 5 days. Your recent trends show something might be off. We’re here for you."
                     : "We noticed you haven’t checked in for a few days. Everything okay?")
                    .font(.body)
                    .foregroundColor(.primary)

                HStack {
                    NavigationLink(destination: HomeCheckInView()) {
                        Text("Check In Now")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color("BrandBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    if missedDays < 5 {
                        NavigationLink(destination: ResourcesAndLearningView()) {
                            Text("Explore Resources")
                                .font(.subheadline)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }

                    Button("Dismiss") {
                        showAbsencePrompt = false
                        if missedDays == 5 {
                            dismissedAbsencePromptAt5Days = true
                        }
                    }
                    .font(.subheadline)
                    .padding(8)
                    .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
    }

    var moodTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().padding(.top)

            Text("📈 Mood Trend")
                .font(.headline)
                .padding(.horizontal)

            if !recentMoodData.isEmpty {
                Chart {
                    ForEach(recentMoodData) { checkIn in
                        LineMark(
                            x: .value("Date", checkIn.date),
                            y: .value("Mood", checkIn.moodRating)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(Color("BrandBlue"))
                        .symbol(Circle())

                        PointMark(
                            x: .value("Date", checkIn.date),
                            y: .value("Mood", checkIn.moodRating)
                        )
                        .foregroundStyle(Color("BrandBlue"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 2, 4, 6, 8, 10]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .frame(height: 120)
                .padding(.horizontal)

                Text("Avg Mood: \(averageMood)/10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Text("Mood trend chart will appear here.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .padding(.horizontal)
    }

    // ✅ FIXED SECTION BELOW
    var checkInCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(checkInStore.hasCheckedInToday ? "✅ You’ve checked in today." : "🕒 Haven’t checked in yet.")
                    .font(.headline)

                NavigationLink(destination: HomeCheckInView()) {
                    Text(checkInStore.hasCheckedInToday ? "Check In Again" : "Check In Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BrandBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }

    var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("💡 Insight")
                .font(.headline)

            Text(generateInsight())
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    func generateInsight() -> String {
        guard checkInStore.checkIns.count >= 5 else {
            return "Insights will appear once we have enough data."
        }

        guard let baseline = userProfileStore.profile else {
            return "Baseline not set yet — check in to get started."
        }

        let recent = checkInStore.checkIns.suffix(7)
        guard !recent.isEmpty else {
            return "No check-ins found for this week."
        }

        let moodAvg = recent.map { $0.moodRating }.average
        let sleepAvg = recent.map { $0.sleepQuality }.average
        let anxietyAvg = recent.map { $0.anxietyLevel }.average

        var insights: [String] = []

        if moodAvg < baseline.baselineMood - 2 {
            insights.append("Your mood this week averaged \(baseline.baselineMood - moodAvg) points below your baseline.")
        } else if moodAvg >= baseline.baselineMood + 2 {
            insights.append("Your mood has been noticeably better than your baseline this week. Keep it up.")
        }

        if sleepAvg < baseline.baselineSleep - 2 {
            insights.append("You’ve been sleeping worse than usual for several days.")
        } else if sleepAvg > baseline.baselineSleep + 2 {
            insights.append("Your sleep quality has improved compared to your baseline.")
        }

        if anxietyAvg > baseline.baselineAnxiety + 2 {
            insights.append("Your anxiety has been consistently above your norm.")
        } else if anxietyAvg < baseline.baselineAnxiety - 2 {
            insights.append("You've been less anxious than usual this week.")
        }

        return insights.randomElement() ?? "Keep checking in — we’ll surface helpful patterns over time."
    }
}

// MARK: - Dashboard Card Link Component

struct DashboardCardLink<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    var iconColor: Color = Color("BrandBlue") // <-- Add this line

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor) // <-- Use this here

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}
