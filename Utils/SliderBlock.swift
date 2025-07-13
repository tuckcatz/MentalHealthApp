import SwiftUI

struct SliderBlock: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(Int(value))")
                .font(.subheadline)
                .bold()
            Slider(value: $value, in: 1...10, step: 1)
                .tint(Color("BrandBlue")) // ✅ Apply brand color
        }
        .padding(.vertical, 4)
    }
}
