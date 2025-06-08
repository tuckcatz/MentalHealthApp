import SwiftUI

struct CheckInDetailView: View {
    let checkIn: CheckIn

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Check-In Details")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("BrandBlue"))
                        .padding(.bottom, 10)

                    Group {
                        labeled("Date", text: formattedDate(checkIn.date))
                        labeled("Mood", text: "\(checkIn.moodRating)/10")
                        labeled("Energy", text: "\(checkIn.energyLevel)/10")
                        labeled("Sleep", text: "\(checkIn.sleepQuality)/10")
                        labeled("Appetite", text: "\(checkIn.appetiteLevel)/10")
                        labeled("Anxiety", text: "\(checkIn.anxietyLevel)/10")
                        labeled("Interest", text: "\(checkIn.interestLevel)/10")
                        labeled("Hopelessness", text: "\(checkIn.hopelessnessLevel)/10")
                        labeled("Felt Safe", text: checkIn.feelsSafe ? "Yes" : "No")
                        labeled("Harm Thoughts", text: checkIn.hasHarmThoughts ? "Yes" : "No")
                    }

                    if !checkIn.feelings.isEmpty {
                        labeled("Feelings", text: checkIn.feelings.joined(separator: ", "))
                    }

                    if let journal = checkIn.journalText, !journal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Journal Entry")
                                .font(.headline)
                            Text(journal)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    if let imageData = checkIn.journalImageData,
                       let uiImage = UIImage(data: imageData) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Journal Photo")
                                .font(.headline)

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Details")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func labeled(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    let sample = CheckIn(
        date: Date(),
        moodRating: 3,
        energyLevel: 2,
        sleepQuality: 4,
        appetiteLevel: 3,
        anxietyLevel: 5,
        interestLevel: 2,
        hopelessnessLevel: 7,
        feelsSafe: false,
        hasHarmThoughts: true,
        feelings: ["Hopeless", "Tired"],
        journalText: "Not feeling great today.",
        journalImageData: nil
    )

    return CheckInDetailView(checkIn: sample)
}
