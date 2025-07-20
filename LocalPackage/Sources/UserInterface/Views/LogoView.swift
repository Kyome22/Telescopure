import SwiftUI

struct LogoView: View {
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            Image(.monoIcon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(Color(.systemGray5))
            Text("telescopure")
                .italic()
                .bold()
                .foregroundColor(Color(.systemGray5))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    LogoView()
}
