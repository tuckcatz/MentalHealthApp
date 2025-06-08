import SwiftUI

struct MoodCalendarView: View {
    @EnvironmentObject var checkInStore: CheckInStore

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    @State private var displayedMonth: Date = Date()
    @State private var selectedCheckIn: CheckIn?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Mood Calendar")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Month Navigation
                    Card {
                        HStack {
                            Button(action: { displayedMonth = adjustMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color("BrandBlue"))
                            }

                            Spacer()

                            Text(currentMonthYear)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            Button(action: { displayedMonth = adjustMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("BrandBlue"))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Calendar Grid
                    Card {
                        SectionHeader(title: "🗓️ Mood Calendar")

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                                Text(day.prefix(3))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            ForEach(daysInMonth(), id: \.self) { date in
                                let matchingCheckIn = checkInStore.checkIns.first(where: {
                                    calendar.isDate($0.date, inSameDayAs: date)
                                })

                                ZStack {
                                    Circle()
                                        .fill(moodColor(matchingCheckIn?.moodRating))
                                        .frame(height: 36)

                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                                .onTapGesture {
                                    if let checkIn = matchingCheckIn {
                                        selectedCheckIn = checkIn
                                    }
                                }
                            }
                        }
                    }

                    // Back to Trends
                    Card {
                        NavigationLink(destination: TrendAnalysisView()) {
                            Text("Back to Trends")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("BrandBlue").opacity(0.1))
                                .foregroundColor(Color("BrandBlue"))
                                .cornerRadius(12)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Mood Calendar")
            .sheet(item: $selectedCheckIn) { checkIn in
                CheckInDetailView(checkIn: checkIn)
            }
        }
    }

    // MARK: - Helper Functions

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func adjustMonth(by value: Int) -> Date {
        calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }

    private func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let startWeekday = calendar.component(.weekday, from: monthStart)
        let padding = Array(repeating: Date.distantPast, count: startWeekday - 1)

        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }

        return padding + days
    }

    private func moodColor(_ mood: Int?) -> Color {
        guard let mood = mood else { return Color.gray.opacity(0.2) }

        switch mood {
        case 1...3: return Color.red.opacity(0.7)
        case 4...6: return Color.yellow.opacity(0.7)
        case 7...10: return Color.green.opacity(0.7)
        default: return Color.gray
        }
    }
}

#Preview {
    MoodCalendarView()
        .environmentObject(CheckInStore())
}
