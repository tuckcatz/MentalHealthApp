import SwiftUI

struct CheckInHistoryView: View {
    @EnvironmentObject var checkInStore: CheckInStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(checkInStore.checkIns.reversed()) { checkIn in
                    NavigationLink(destination: CheckInDetailView(checkIn: checkIn)) {
                        VStack(alignment: .leading) {
                            Text(checkIn.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("Mood: \(checkIn.moodRating)")
                                .font(.headline)

                            if !checkIn.feelings.isEmpty {
                                Text(checkIn.feelings.joined(separator: ", "))
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
