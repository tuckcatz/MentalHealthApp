import SwiftUI
import PhotosUI

struct HomeCheckInView: View {
    @AppStorage("checkInDeferredUntil") var checkInDeferredUntil: Date = .distantPast
    @AppStorage("shouldShowCheckIn") var shouldShowCheckIn: Bool = true

    @State private var moodRating: Double = 5
    @State private var energyLevel: Double = 5
    @State private var sleepQuality: Double = 5
    @State private var appetiteLevel: Double = 5
    @State private var anxietyLevel: Double = 5
    @State private var interestLevel: Double = 5
    @State private var hopelessnessLevel: Double = 5
    @State private var feelsSafe: Bool = true
    @State private var hasHarmThoughts: Bool = false

    @EnvironmentObject var userProfileStore: UserProfileStore
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var alertManager: AlertManager
    @Environment(\.dismiss) var dismiss

    @State private var journalText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var journalImage: Image? = nil
    @State private var journalImageData: Data?

    @State private var selectedFeelings: [FeelingWord] = []
    @StateObject private var feelingWordsStore = FeelingWordsStore()

    @State private var navigateToConfirmation = false
    @State private var navigateToCoping = false
    @State private var navigateToAlert = false

    var balancedDailyFeelings: [FeelingWord] {
        let shuffled = feelingWordsStore.allWords.shuffled()

        let pos = shuffled.filter { $0.category == .positive }.prefix(2)
        let risk = shuffled.filter { $0.category == .highRisk }.prefix(2)
        let mild = shuffled.filter { $0.category == .mildNegative || $0.category == .neutral }.prefix(2)

        return Array((pos + risk + mild).shuffled())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Text("Daily Check-In")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(Color("BrandBlue"))

                    Card {
                        SectionHeader(title: "🧠 How Are You Feeling?")
                        VStack(spacing: 12) {
                            SliderBlock(title: "Mood", value: $moodRating)
                            SliderBlock(title: "Energy", value: $energyLevel)
                            SliderBlock(title: "Sleep", value: $sleepQuality)
                            SliderBlock(title: "Appetite", value: $appetiteLevel)
                            SliderBlock(title: "Anxiety", value: $anxietyLevel)
                            SliderBlock(title: "Enjoyment in Activities", value: $interestLevel)
                            SliderBlock(title: "Hopelessness", value: $hopelessnessLevel)

                            Toggle("I feel safe today", isOn: $feelsSafe)
                            Toggle("I've had thoughts of harming myself", isOn: $hasHarmThoughts)
                        }
                    }

                    Card {
                        SectionHeader(title: "💬 Tap Any That Apply")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                            ForEach(balancedDailyFeelings, id: \.word) { feeling in
                                Text(feeling.word)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedFeelings.contains(where: { $0.word == feeling.word }) ? Color("BrandBlue") : backgroundColor(for: feeling.category))
                                    .foregroundColor(selectedFeelings.contains(where: { $0.word == feeling.word }) ? .white : .primary)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        toggleFeeling(feeling)
                                    }
                            }
                        }
                    }

                    Card {
                        SectionHeader(title: "📓 Journal (recommended)")
                        TextEditor(text: $journalText)
                            .frame(height: 140)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }

                    Card {
                        SectionHeader(title: "📸 Add a Journal Photo (Optional)")
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Select Photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }

                        if let image = journalImage {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(10)
                        }
                    }

                    Card {
                        VStack(spacing: 12) {
                            Button(action: handleSubmit) {
                                Text("Submit Check-In")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("BrandBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                            }

                            // ✅ Dynamic "Remind Me Later" or "Dismiss"
                            Button(action: {
                                if !checkInStore.hasCheckedInToday {
                                    checkInDeferredUntil = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date().addingTimeInterval(7200)
                                    shouldShowCheckIn = false
                                    dismiss() // ✅ ADD THIS LINE
                                } else {
                                    dismiss()
                                }
                            }) {
                                Text(checkInStore.hasCheckedInToday ? "Dismiss" : "Remind Me Later")
                                    .font(.subheadline)
                                    .foregroundColor(Color("BrandBlue"))
                                    .padding(.vertical, 8)
                            }

                            NavigationLink(destination: ConfirmationView(), isActive: $navigateToConfirmation) { EmptyView() }
                            NavigationLink(destination: CopingSupportView(), isActive: $navigateToCoping) { EmptyView() }
                            NavigationLink(destination: HighRiskSupportView(), isActive: $navigateToAlert) { EmptyView() }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .navigationTitle("Check-In")
            .navigationBarBackButtonHidden(true)
        }
    }

    func handleSubmit() {
        processPhoto()

        let riskResult = RiskEngine.evaluate(
            journalText: journalText,
            feelings: selectedFeelings.map { $0.word },
            mood: Int(moodRating),
            energy: Int(energyLevel),
            sleep: Int(sleepQuality),
            appetite: Int(appetiteLevel),
            anxiety: Int(anxietyLevel),
            interest: Int(interestLevel),
            hopelessness: Int(hopelessnessLevel),
            feelsSafe: feelsSafe,
            hasHarmThoughts: hasHarmThoughts,
            moodTrend: checkInStore.recentMoodTrend,
            userProfile: userProfileStore.profile
        )

        checkInStore.addCheckIn(
            mood: Int(moodRating),
            energy: Int(energyLevel),
            sleep: Int(sleepQuality),
            appetite: Int(appetiteLevel),
            anxiety: Int(anxietyLevel),
            interest: Int(interestLevel),
            hopelessness: Int(hopelessnessLevel),
            feelsSafe: feelsSafe,
            hasHarmThoughts: hasHarmThoughts,
            feelings: selectedFeelings,
            journal: journalText,
            journalImage: journalImageData
        )

        // ✅ Reset suppression after check-in
        shouldShowCheckIn = true
        checkInDeferredUntil = .distantPast

        switch riskResult.level {
        case .critical:
            alertManager.sendAlerts(for: riskResult)
            navigateToAlert = true
        case .high:
            navigateToCoping = true
        case .moderate, .low:
            navigateToConfirmation = true
        }
    }

    func processPhoto() {
        guard let item = selectedPhoto else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                journalImageData = data
                if let uiImage = UIImage(data: data) {
                    journalImage = Image(uiImage: uiImage)
                }
            }
        }
    }

    func toggleFeeling(_ feeling: FeelingWord) {
        if let index = selectedFeelings.firstIndex(where: { $0.word == feeling.word }) {
            selectedFeelings.remove(at: index)
        } else {
            selectedFeelings.append(feeling)
        }
    }

    func backgroundColor(for category: FeelingCategory) -> Color {
        switch category {
        case .positive:
            return Color.green.opacity(0.2)
        case .mildNegative:
            return Color.orange.opacity(0.2)
        case .highRisk:
            return Color.red.opacity(0.2)
        case .neutral:
            return Color.gray.opacity(0.2)
        @unknown default:
            return Color.black.opacity(0.2)
        }
    }
}
