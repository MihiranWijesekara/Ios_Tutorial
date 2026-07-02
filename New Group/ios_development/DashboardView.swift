import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) { // Keeps a tight, uniform layout structure
                Text("Game Hub")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .padding(.top, 50)
                
                Spacer()
                
                // Button for Game 01 (Your original ContentView)
                NavigationLink(destination: ContentView()) {
                    Text("Tap Frenzy")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                // Button for Game 02 (Week 2 Game)
                NavigationLink(destination: LightItUpView()) {
                    Text("Light It Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.purple)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                // Button for Game 03 (Week 3 - Quiz Rush)
                NavigationLink(destination: QuizRushView()) {
                    Text("Quiz Rush")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.orange) // Changed to orange for visual variety!
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
