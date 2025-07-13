import SwiftUI
import Charts
import UIKit

struct TrendAnalysisView: View {
    @EnvironmentObject var checkInStore: CheckInStore
    @State private var show14DayView = false

    var dataset: [CheckIn] {
        let all = checkInStore.checkIns.suffix(14)
        return show14DayView ? Array(all) : Array(all.suffix(7))
    }

    var previous7: [CheckIn] {
        let all = checkInStore.checkIns.suffix(14)
        return Array(all.prefix(max(0, all.count - 7)))
    }

    var moodAvg: Int { dataset.map { $0.moodRating }.average }
    var moodPrev: Int { previous7.map { $0.moodRating }.average }

    var energyAvg: Int { dataset.map { $0.energyLevel }.average }
    var energyPrev: Int { previous7.map { $0.energyLevel }.average }

    var anxietyAvg: Int { dataset.map { $0.anxietyLevel }.average }
    var anxietyPrev: Int { previous7.map { $0.anxietyLevel }.average }

    var sleepAvg: Int { dataset.map { $0.sleepQuality }.average }
    var sleepPrev: Int { previous7.map { $0.sleepQuality }.average }

    var appetiteAvg: Int { dataset.map { $0.appetiteLevel }.average }
    var appetitePrev: Int { previous7.map { $0.appetiteLevel }.average }

    var mostCommonWords: [String] {
        let all = dataset.flatMap { $0.feelings }  // [FeelingWord]
        let counts = Dictionary(grouping: all, by: { $0.word }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.prefix(2).map { $0.key }
    }
    
    var journalBoostInsight: String? {
        let journalDays = dataset.filter { !($0.journalText?.isEmpty ?? true) }
        let nonJournalDays = dataset.filter { ($0.journalText?.isEmpty ?? true) }

        let journalAvg = journalDays.map { $0.moodRating }.average
        let nonJournalAvg = nonJournalDays.map { $0.moodRating }.average

        if journalAvg > nonJournalAvg && !journalDays.isEmpty && !nonJournalDays.isEmpty {
            return "Your mood tends to be higher on days you journal."
        } else {
            return nil
        }
    }

    var highRiskAlert: String? {
        let store = FeelingWordsStore()
        let highRiskSet = Set(store.allWords.filter { $0.category == .highRisk }.map { $0.word })

        let count = dataset.filter {
            $0.feelings.contains(where: { highRiskSet.contains($0.word) })
        }.count

        return count >= 3 ? "You've selected high-risk words on \(count) of your recent check-ins." : nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Your Mood Trends")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("BrandBlue"))

                Toggle(isOn: $show14DayView) {
                    Text(show14DayView ? "Showing 14-Day View" : "Showing 7-Day View")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                if dataset.isEmpty {
                    Text("Not enough check-ins yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Card {
                        SectionHeader(title: "📊 Summary")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                MetricSummaryCard(emoji: "😊", title: "Mood", average: moodAvg, delta: moodAvg - moodPrev)
                                MetricSummaryCard(emoji: "⚡️", title: "Energy", average: energyAvg, delta: energyAvg - energyPrev)
                                MetricSummaryCard(emoji: "😰", title: "Anxiety", average: anxietyAvg, delta: anxietyAvg - anxietyPrev, inverse: true)
                                MetricSummaryCard(emoji: "😴", title: "Sleep", average: sleepAvg, delta: sleepAvg - sleepPrev)
                                MetricSummaryCard(emoji: "🍽️", title: "Appetite", average: appetiteAvg, delta: appetiteAvg - appetitePrev)
                            }
                        }
                    }

                    ChartSection(title: "Mood", keyPath: \.moodRating)
                    ChartSection(title: "Energy", keyPath: \.energyLevel)
                    ChartSection(title: "Anxiety", keyPath: \.anxietyLevel)
                    ChartSection(title: "Sleep", keyPath: \.sleepQuality)
                    ChartSection(title: "Appetite", keyPath: \.appetiteLevel)

                    if journalBoostInsight != nil || highRiskAlert != nil || !mostCommonWords.isEmpty {
                        Card {
                            SectionHeader(title: "💡 Insights")

                            if let insight = journalBoostInsight {
                                Text(insight)
                            }

                            if let alert = highRiskAlert {
                                Text(alert).foregroundColor(.red)
                            }

                            if !mostCommonWords.isEmpty {
                                Text("You've most often felt: \(mostCommonWords.joined(separator: ", "))")
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("📤 Export Your Mood Report")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: exportPDF) {
                            Text("Download PDF")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("BrandBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    NavigationLink(destination: CheckInHistoryView()) {
                        Text("See Full Check-In History")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrandBlue").opacity(0.1))
                            .foregroundColor(Color("BrandBlue"))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Trend Insights")
    }

    func exportPDF() {
        let recent = show14DayView ? checkInStore.checkIns.suffix(14) : checkInStore.checkIns.suffix(7)
        let checkInsArray = Array(recent)

        guard let start = checkInsArray.first?.date,
              let end = checkInsArray.last?.date else { return }

        let range = start...end
        guard let pdfData = PDFExporter.createTrendPDF(from: checkInsArray, dateRange: range) else { return }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MoodTrend.pdf")
        try? pdfData.write(to: tempURL)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Chart Section

struct ChartSection: View {
    let title: String
    let keyPath: KeyPath<CheckIn, Int>
    @EnvironmentObject var checkInStore: CheckInStore
    @Environment(\.trendRange) var trendRange

    var data: [CheckIn] {
        let all = checkInStore.checkIns.suffix(14)
        return trendRange.wrappedValue ? Array(all) : Array(all.suffix(7))
    }

    var body: some View {
        Card {
            SectionHeader(title: title)

            Chart {
                ForEach(data) { checkIn in
                    LineMark(
                        x: .value("Date", checkIn.date.formatted(.dateTime.month().day())),
                        y: .value(title, checkIn[keyPath: keyPath])
                    )
                    .interpolationMethod(.linear)
                    .symbol(Circle())
                    .foregroundStyle(Color("BrandBlue"))
                }
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Summary Card

struct MetricSummaryCard: View {
    let emoji: String
    let title: String
    let average: Int
    let delta: Int
    var inverse: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji).font(.largeTitle)
            Text(title).font(.headline)
            Text("Avg: \(average)").font(.subheadline)
            Text(deltaText).font(.caption).foregroundColor(deltaColor)
        }
        .padding()
        .frame(width: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }

    private var deltaText: String {
        if delta == 0 {
            return "↔︎ No change"
        } else if delta > 0 {
            return inverse ? "⬆︎ \(delta)" : "⬆︎ +\(delta)"
        } else {
            return inverse ? "⬇︎ \(abs(delta))" : "⬇︎ \(abs(delta))"
        }
    }

    private var deltaColor: Color {
        if delta == 0 {
            return .gray
        } else {
            return (inverse ? delta < 0 : delta > 0) ? .green : .red
        }
    }
}

// MARK: - Toggle Binding

private struct TrendRangeKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var trendRange: Binding<Bool> {
        get { self[TrendRangeKey.self] }
        set { self[TrendRangeKey.self] = newValue }
    }
}

extension Array where Element == Int {
    var average: Int {
        guard !self.isEmpty else { return 0 }
        return self.reduce(0, +) / self.count
    }
}
