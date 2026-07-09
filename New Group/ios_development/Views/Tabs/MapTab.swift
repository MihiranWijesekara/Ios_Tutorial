import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var locationService: LocationService
    @StateObject private var statsVM = StatsVM()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedSession: GameSession? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $position, selection: $selectedSession) {
                    ForEach(statsVM.sessions) { session in
                        if session.latitude != 0.0 || session.longitude != 0.0 {
                            Marker(coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                                Label("\(session.score)", systemImage: session.mode.iconName)
                            }
                            .tag(session)
                            .tint(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .purple : .orange)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                
                // Details Card Overlay
                if let session = selectedSession {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(session.mode == .tapFrenzy ? Color.blue.opacity(0.2) : session.mode == .lightItUp ? Color.purple.opacity(0.2) : Color.orange.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Image(systemName: session.mode.iconName)
                                    .foregroundColor(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .purple : .orange)
                            }
                            
                            Text(session.mode.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { selectedSession = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SCORE")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("\(session.score) pts")
                                    .font(.system(.body, design: .monospaced, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("COMPLETED ON")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(session.timestamp.formatted(.dateTime.month().day().hour().minute()))
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Map of Games")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .onAppear {
                statsVM.loadSessions()
                locationService.requestPermission()
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedSession)
        }
    }
}

//import SwiftUI
//import MapKit
//import CoreLocation
//
//struct MapTab: View {
//    @EnvironmentObject var locationService: LocationService
//    @StateObject private var statsVM = StatsVM()
//    
//    // Hardcoded Colombo, Sri Lanka coordinates to bypass Mac admin/GPS blocks
//    @State private var position: MapCameraPosition = .camera(
//        MapCamera(
//            centerCoordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
//            distance: 15000 
//        )
//    )
//    @State private var selectedSession: GameSession? = nil
//    
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .bottom) {
//                Map(position: $position, selection: $selectedSession) {
//                    ForEach(statsVM.sessions) { session in
//                        if session.latitude != 0.0 || session.longitude != 0.0 {
//                            Marker(coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
//                                Label("\(session.score)", systemImage: session.mode.iconName)
//                            }
//                            .tag(session)
//                            .tint(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .purple : .orange)
//                        }
//                    }
//                }
//                .mapControls {
//                    MapUserLocationButton()
//                    MapCompass()
//                }
//                
//                // Details Card Overlay
//                if let session = selectedSession {
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(session.mode == .tapFrenzy ? Color.blue.opacity(0.2) : session.mode == .lightItUp ? Color.purple.opacity(0.2) : Color.orange.opacity(0.2))
//                                    .frame(width: 32, height: 32)
//                                Image(systemName: session.mode.iconName)
//                                    .foregroundColor(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .purple : .orange)
//                            }
//                            
//                            Text(session.mode.rawValue)
//                                .font(.headline)
//                                .foregroundColor(.white)
//                            
//                            Spacer()
//                            
//                            Button(action: { selectedSession = nil }) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.title3)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        
//                        HStack(spacing: 24) {
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text("SCORE")
//                                    .font(.caption2)
//                                    .foregroundColor(.gray)
//                                Text("\(session.score) pts")
//                                    .font(.system(.body, design: .monospaced, weight: .bold))
//                                    .foregroundColor(.white)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text("COMPLETED ON")
//                                    .font(.caption2)
//                                    .foregroundColor(.gray)
//                                Text(session.timestamp, style: .date)
//                                    .font(.body)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(white: 0.12))
//                    .cornerRadius(16)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
//                    )
//                    .padding()
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                }
//            }
//            .navigationTitle("Map of Games")
//            .navigationBarTitleDisplayMode(.inline)
//            .preferredColorScheme(.dark)
//            .onAppear {
//                statsVM.loadSessions()
//                locationService.requestPermission()
//            }
//            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedSession)
//        }
//    }
//}
