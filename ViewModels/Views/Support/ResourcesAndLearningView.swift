import SwiftUI

struct ResourcesAndLearningView: View {
    let articles: [(title: String, url: String)] = [
        ("5 Grounding Techniques for Anxiety", "https://psychcentral.com/health/grounding-techniques"),
        ("The Science of Journaling", "https://positivepsychology.com/benefits-of-journaling/"),
        ("Breathing Exercises That Calm You", "https://www.healthline.com/health/breathing-exercise"),
        ("CBT Tools for Self-Awareness", "https://www.verywellmind.com/cognitive-behavioral-therapy-techniques-2795963")
    ]

    let affirmations = [
        "You’re allowed to rest, reflect, and reset.",
        "Your effort matters even when no one sees it.",
        "Small steps are still progress.",
        "You’re doing better than you think.",
        "Your feelings are valid — all of them.",
        "You are not alone."
    ]

    let tips = [
        "Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.",
        "Take a few deep breaths — in through your nose, out through your mouth.",
        "Drink a full glass of water and stretch your arms.",
        "Write one kind sentence to yourself.",
        "Go outside and notice something beautiful or interesting.",
        "Text someone you trust with a simple 'Hey, thinking of you.'"
    ]

    var dailyAffirmation: String {
        let index = Calendar.current.component(.day, from: Date()) % affirmations.count
        return affirmations[index]
    }

    var dailyTip: String {
        let index = Calendar.current.component(.day, from: Date()) % tips.count
        return tips[index]
    }

    var therapistDirectories: [(title: String, url: String)] = [
        ("Psychology Today", "https://www.psychologytoday.com/us/therapists"),
        ("Mental Health America", "https://mhanational.org/finding-therapy"),
        ("TherapyDen", "https://www.therapyden.com/"),
        ("Open Path Collective", "https://www.openpathcollective.org/")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Mental Health Toolkit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrandBlue"))
                        .padding(.horizontal)

                    // Daily Affirmation
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "🧘 Daily Affirmation")

                        Text("“\(dailyAffirmation)”")
                            .italic()
                            .foregroundColor(Color("BrandBlue"))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Daily Tip
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "🌟 Coping Tip of the Day")

                        Text(dailyTip)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Article Links Block
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "🧠 Learn More")

                        ForEach(articles, id: \.title) { item in
                            if let url = URL(string: item.url) {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "book")
                                            .foregroundColor(Color("BrandBlue"))
                                        Text(item.title)
                                            .foregroundColor(Color("BrandBlue"))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Therapist Directory
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "🔎 Find a Therapist")

                        ForEach(therapistDirectories, id: \.title) { item in
                            if let url = URL(string: item.url) {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "person.fill.questionmark")
                                            .foregroundColor(Color("BrandBlue"))
                                        Text(item.title)
                                            .foregroundColor(Color("BrandBlue"))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Quick Help Button
                    Card {
                        NeedHelpNowButton()
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .navigationTitle("Resources & Learning")
        }
    }
}

#Preview {
    ResourcesAndLearningView()
}
