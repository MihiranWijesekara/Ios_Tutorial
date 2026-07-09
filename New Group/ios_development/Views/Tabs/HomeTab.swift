import SwiftUI

struct HomeTab: View {
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.07)
                    .ignoresSafeArea()
                
                RadialGradient(
                    colors: [Color.purple.opacity(0.12), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Play Hub")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.85), Color.gray.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text("Select an arena to begin")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Arena 1: Tap Frenzy
                        NavigationLink(destination: TapFrenzyView(locationService: locationService)) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Tap Frenzy")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Test your response times")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 76)
                            .background(Color(white: 0.12))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            )
                            .shadow(color: Color.blue.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        
                        // Arena 2: Light It Up
                        NavigationLink(destination: LightItUpView(locationService: locationService)) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "lightbulb.led.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Light It Up")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Illuminate the correct paths")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 76)
                            .background(Color(white: 0.12))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            )
                            .shadow(color: Color.purple.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        
                        // Arena 3: Quiz Rush
                        NavigationLink(destination: QuizRushView(locationService: locationService)) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "timer")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Quiz Rush")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Beat the ticking countdown")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 76)
                            .background(Color(white: 0.12))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            )
                            .shadow(color: Color.orange.opacity(0.15), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
