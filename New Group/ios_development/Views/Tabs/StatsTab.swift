import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var statsVM = StatsVM()
    @State private var selectedMode: GameMode = .tapFrenzy
    
    var selectedModeColor: Color {
        switch selectedMode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .purple
        case .quizRush: return .orange
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.07)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Mode Selection Picker
                        Picker("Game Mode", selection: $selectedMode) {
                            ForEach(GameMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Summary Cards Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PERSONAL BEST")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("\(statsVM.personalBest(for: selectedMode))")
                                    .font(.system(size: 28, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(white: 0.12))
                            .cornerRadius(16)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("TOTAL SCORE")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("\(statsVM.totalScore(for: selectedMode))")
                                    .font(.system(size: 28, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(white: 0.12))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Charts Card Panel
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SCORE TREND")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            let modeSessions = statsVM.sessions(for: selectedMode)
                            
                            if modeSessions.isEmpty {
                                VStack {
                                    Spacer()
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.3))
                                        .padding(.bottom, 8)
                                    Text("No sessions recorded yet")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                            } else {
                                Chart {
                                    ForEach(Array(modeSessions.suffix(10).enumerated()), id: \.element.id) { index, session in
                                        BarMark(
                                            x: .value("Game", index + 1),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(selectedModeColor)
                                        .cornerRadius(4)
                                    }
                                }
                                .chartXScale(domain: 1...max(10, modeSessions.suffix(10).count))
                                .frame(height: 180)
                            }
                        }
                        .padding()
                        .background(Color(white: 0.12))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Recent Games List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RECENT GAMES")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal)
                            
                            if statsVM.sessions.isEmpty {
                                Text("Play some games to populate this list!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(statsVM.sessions.reversed().prefix(5)) { session in
                                        HStack(spacing: 16) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(session.mode == .tapFrenzy ? Color.blue.opacity(0.15) : session.mode == .lightItUp ? Color.purple.opacity(0.15) : Color.orange.opacity(0.15))
                                                    .frame(width: 38, height: 38)
                                                
                                                Image(systemName: session.mode.iconName)
                                                    .foregroundColor(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .purple : .orange)
                                                    .font(.system(size: 16))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(session.mode.rawValue)
                                                    .font(.subheadline).bold()
                                                    .foregroundColor(.white)
                                                Text(session.timestamp, style: .date)
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(session.score) pts")
                                                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .background(Color(white: 0.15))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Stats Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .onAppear {
                statsVM.loadSessions()
            }
        }
    }
}
