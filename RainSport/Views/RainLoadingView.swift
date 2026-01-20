import SwiftUI

struct RainLoadingView: View {
    @State private var rainShowText = false
    @State private var rainGradientOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            RainAnimatedGradientBackground(rainGradientOffset: $rainGradientOffset)
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Rain Sport")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(rainShowText ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0).delay(0.5), value: rainShowText)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Train. Achieve. Excel.")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(rainShowText ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0).delay(1.0), value: rainShowText)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 16, height: 16)
                                .shadow(color: .blue.opacity(0.6), radius: 8, x: 0, y: 4)
                                .scaleEffect(rainShowText ? 1.0 : 0.5)
                                .opacity(rainShowText ? 1.0 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.25),
                                    value: rainShowText
                                )
                        }
                    }
                    
                    Text("Preparing your workout...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(rainShowText ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0).delay(2.0), value: rainShowText)
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation {
                rainShowText = true
            }
            
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
                rainGradientOffset = 0.4
            }
        }
    }
}

struct RainAnimatedGradientBackground: View {
    @Binding var rainGradientOffset: CGFloat
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.15, blue: 0.3),
                    Color(red: 0.0, green: 0.1, blue: 0.25),
                    Color(red: 0.05, green: 0.15, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: UnitPoint(x: 0.5, y: rainGradientOffset),
                endPoint: UnitPoint(x: 0.5, y: 1.0 - rainGradientOffset)
            )
            .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.25),
                    Color.cyan.opacity(0.15),
                    Color.blue.opacity(0.25)
                ]),
                startPoint: UnitPoint(x: rainGradientOffset, y: 0),
                endPoint: UnitPoint(x: 1.0 - rainGradientOffset, y: 1.0)
            )
            .ignoresSafeArea()
            .blendMode(.overlay)
        }
    }
}
