import SwiftUI

struct CopingSupportView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("It’s Okay to Feel This Way")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("BrandBlue"))

                        Text("Everyone has tough days. You’re doing your best — and that’s enough. Here are a few ways to ground yourself and reset.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "💡 Quick Ways to Regroup")

                        Text("🧘 Try the 5-4-3-2-1 grounding method")
                        Text("📝 Jot down a quick thought or feeling")
                        Text("🌤 Step outside or stretch your arms")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 16) {
                        NavigationLink(destination: ResourcesAndLearningView()) {
                            Text("Explore More Resources")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }

                        NavigationLink(destination: DashboardView()) {
                            Text("Continue to Dashboard")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40) // ✅ Moves content down away from top notch
                .padding(.bottom, 20)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
