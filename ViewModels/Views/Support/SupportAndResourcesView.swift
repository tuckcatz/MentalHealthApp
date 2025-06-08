import SwiftUI

struct SupportAndResourcesView: View {
    let articles: [(title: String, url: String)] = [
        ("5 Grounding Techniques for Anxiety", "https://psychcentral.com/health/grounding-techniques"),
        ("The Science of Journaling", "https://positivepsychology.com/benefits-of-journaling/"),
        ("Breathing Exercises That Calm You", "https://www.healthline.com/health/breathing-exercise"),
        ("Cognitive Behavioral Tools for Self-Awareness", "https://www.verywellmind.com/cognitive-behavioral-therapy-techniques-2795963")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Support & Resources")
                    .font(.largeTitle)
                    .bold()

                // Affirmation or grounding
                VStack(alignment: .leading, spacing: 8) {
                    Text("🧘 Self-Guided Tools")
                        .font(.title2)
                        .bold()

                    Text("“You are doing better than you think.”")
                        .italic()
                        .foregroundColor(.blue)

                    Text("🌱 Try This:")
                        .bold()
                    Text("Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                // Article links
                VStack(alignment: .leading, spacing: 12) {
                    Text("🧠 Learn More")
                        .font(.title2)
                        .bold()

                    ForEach(articles, id: \.title) { item in
                        if let url = URL(string: item.url) {
                            Link(item.title, destination: url)
                                .foregroundColor(.blue)
                        }
                    }
                }

                Divider()

                // Crisis support
                VStack(alignment: .leading, spacing: 12) {
                    Text("🚨 Get Help Now")
                        .font(.title2)
                        .bold()

                    Text("If you're in crisis or need to talk to someone now:")

                    Link("📞 Call 988 – Suicide & Crisis Lifeline", destination: URL(string: "tel://988")!)
                        .foregroundColor(.blue)

                    Link("💬 Text HELLO to 741741 – Crisis Text Line", destination: URL(string: "https://www.crisistextline.org")!)

                    Link("🌍 Befrienders.org – International Help", destination: URL(string: "https://www.befrienders.org")!)
                }

                Divider()

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Support & Resources")
    }
}

#Preview {
    SupportAndResourcesView()
}
