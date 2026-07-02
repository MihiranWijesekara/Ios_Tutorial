import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Game Hub")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .padding(.top, 50)
                
                Spacer()
                
                // Button for Game 01 (Your original ContentView)
                NavigationLink(destination: ContentView()) {
                    Text("Tap frenzy")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                // Button for Game 02 (New Game)
                NavigationLink(destination: LightItUpView()) {
                    Text("Light It Up") // You can change this title later
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.purple)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    DashboardView()
}
