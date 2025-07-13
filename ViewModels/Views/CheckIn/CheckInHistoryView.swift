import SwiftUI

struct CheckInHistoryView: View {
    @EnvironmentObject var checkInStore: CheckInStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(checkInStore.checkIns.reversed()) { checkIn in
                    NavigationLink(destination: CheckInDetailView(checkIn: checkIn)) {
                        VStack(alignment: .leading) {
                            // Format and show the date
                            let formattedDate = checkIn.date.formatted(date: .abbreviated, time: .shortened)
                            Text(formattedDate)
                                .font(.caption)
                                .foregroundColor(.gray)

                            // Mood rating
                            Text("Mood: \(checkIn.moodRating)")
                                .font(.headline)

                            // Show feelings if available
                            if !checkIn.feelings.isEmpty {
                                let feelingWords = checkIn.feelings.map { $0.word }.joined(separator: ", ")
                                Text(feelingWords)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Mood History")
        }
    }
}

#Preview {
    CheckInHistoryView()
        .environmentObject(CheckInStore())
}
