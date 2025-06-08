import SwiftUI

struct CreateProfileView: View {
    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.title2)

            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            NavigationLink(destination: BaselineSurveyView()) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(name.isEmpty)
        }
        .padding()
    }
}

#Preview {
    CreateProfileView()
}
