import SwiftUI

struct DVDLogoView: View {
    let color: Color
    let mainText: String
    let subText: String

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let resolvedMain = mainText.isEmpty ? " " : mainText
            let resolvedSub = subText.isEmpty ? " " : subText
            let mainKerning = mainText.count >= 4 ? -w * 0.020 : -w * 0.035

            ZStack {
                Text(resolvedMain)
                    .font(.system(size: h * 0.92, weight: .black, design: .serif))
                    .italic()
                    .kerning(mainKerning)
                    .foregroundStyle(color)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: w * 0.96, maxHeight: .infinity, alignment: .top)
                    .offset(y: -h * 0.10)

                ZStack {
                    Ellipse()
                        .fill(color)
                        .frame(width: w * 0.62, height: h * 0.22)
                    Text(resolvedSub)
                        .font(.system(size: h * 0.15, weight: .heavy))
                        .tracking(w * 0.005)
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: w * 0.55)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: -h * 0.05)
            }
            .compositingGroup()
            .shadow(color: color.opacity(0.35), radius: h * 0.06)
        }
    }
}
