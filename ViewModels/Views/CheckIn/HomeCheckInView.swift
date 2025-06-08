import SwiftUI
import PhotosUI

struct HomeCheckInView: View {
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

    @State private var journalText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var journalImage: Image? = nil
    @State private var journalImageData: Data?

    @State private var selectedFeelings: [String] = []

    var balancedDailyFeelings: [FeelingWord] {
        let seed = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        var generator = SeededRandomNumberGenerator(seed: UInt64(seed))

        let pos = FeelingWord.positive.shuffled(using: &generator).prefix(2)
        let risk = FeelingWord.highRisk.shuffled(using: &generator).prefix(2)
        let mild = (FeelingWord.mildNegative + FeelingWord.neutral).shuffled(using: &generator).prefix(2)

        return Array((pos + risk + mild).shuffled(using: &generator))
    }

    @State private var navigateToConfirmation = false
    @State private var navigateToCoping = false
    @State private var navigateToAlert = false

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
                                    .background(selectedFeelings.contains(feeling.word) ? Color("BrandBlue") : backgroundColor(for: feeling.category))
                                    .foregroundColor(selectedFeelings.contains(feeling.word) ? .white : .primary)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        toggleFeeling(feeling.word)
                                    }
                            }
                        }
                    }

                    Card {
                        SectionHeader(title: "📓 Journal (Optional)")
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

                        NavigationLink(destination: ConfirmationView(), isActive: $navigateToConfirmation) { EmptyView() }
                        NavigationLink(destination: CopingSupportView(), isActive: $navigateToCoping) { EmptyView() }
                        NavigationLink(destination: HighRiskSupportView(), isActive: $navigateToAlert) { EmptyView() }
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
            feelings: selectedFeelings,
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

    func toggleFeeling(_ word: String) {
        if selectedFeelings.contains(word) {
            selectedFeelings.removeAll { $0 == word }
        } else {
            selectedFeelings.append(word)
        }
    }

    func backgroundColor(for category: FeelingCategory) -> Color {
        switch category {
        case .positive: return Color.green.opacity(0.2)
        case .mildNegative: return Color.orange.opacity(0.2)
        case .highRisk: return Color.red.opacity(0.2)
        case .neutral: return Color.gray.opacity(0.2)
        }
    }
}

// MARK: - Feeling Tags

struct FeelingWord: Hashable {
    let word: String
    let category: FeelingCategory

    static let positive: [FeelingWord] = [
        .init(word: "Calm", category: .positive),
        .init(word: "Hopeful", category: .positive),
        .init(word: "Grateful", category: .positive),
        .init(word: "Connected", category: .positive),
        .init(word: "Relieved", category: .positive),
        .init(word: "Motivated", category: .positive)
    ]

    static let mildNegative: [FeelingWord] = [
        .init(word: "Worried", category: .mildNegative),
        .init(word: "Tired", category: .mildNegative),
        .init(word: "Irritable", category: .mildNegative),
        .init(word: "Distracted", category: .mildNegative),
        .init(word: "Overthinking", category: .mildNegative),
        .init(word: "Frustrated", category: .mildNegative)
    ]

    static let neutral: [FeelingWord] = [
        .init(word: "Meh", category: .neutral),
        .init(word: "Flat", category: .neutral),
        .init(word: "Unsure", category: .neutral),
        .init(word: "Blank", category: .neutral)
    ]

    static let highRisk: [FeelingWord] = [
        .init(word: "Empty", category: .highRisk),
        .init(word: "Hopeless", category: .highRisk),
        .init(word: "Numb", category: .highRisk),
        .init(word: "Disconnected", category: .highRisk),
        .init(word: "Overwhelmed", category: .highRisk),
        .init(word: "Isolated", category: .highRisk),
        .init(word: "Worthless", category: .highRisk),
        .init(word: "Suicidal", category: .highRisk)
    ]
}

enum FeelingCategory {
    case positive, mildNegative, highRisk, neutral
}

struct SliderBlock: View {
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

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

extension Array {
    func shuffled(using generator: inout some RandomNumberGenerator) -> [Element] {
        var copy = self
        copy.shuffle(using: &generator)
        return copy
    }
}
