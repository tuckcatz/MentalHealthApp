import SwiftUI

struct AbsenceBannerView: View {
    let missedDays: Int

    var body: some View {
        NavigationLink(destination: HomeCheckInView()) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                    .imageScale(.medium)

                VStack(alignment: .leading, spacing: 4) {
                    Text(bannerTitle)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Tap here to check in now and get back on track.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color("BrandBlue"))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    var bannerTitle: String {
        switch missedDays {
        case 2:
            return "You’ve missed 2 days of check-ins."
        case 3:
            return "It’s been 3 days. Let’s check in?"
        case 4:
            return "4 missed days. Please check in today."
        case 5:
            return "You’ve missed 5 days — trends matter."
        default:
            return "Let’s get you back on track."
        }
    }
}
