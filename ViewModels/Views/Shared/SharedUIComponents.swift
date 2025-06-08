import SwiftUI

// MARK: - Reusable Card Layout

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
                .frame(maxWidth: .infinity, alignment: .leading) // ✅ FORCES stretch
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section Header (Globally Available)

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.bottom, 4)
    }
}

// MARK: - Crisis Button

struct NeedHelpNowButton: View {
    var body: some View {
        NavigationLink(destination: CrisisSupportView()) {
            Text("🚨 Need Help Now?")
                .font(.subheadline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.05))
                .cornerRadius(10)
        }
    }
}
