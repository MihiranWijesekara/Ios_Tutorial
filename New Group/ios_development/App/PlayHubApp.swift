import SwiftUI

@main
struct PlayHubApp: App {
    @StateObject private var locationService = LocationService()
    @StateObject private var notificationService = NotificationService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(locationService)
                .environmentObject(notificationService)
                .onAppear {
                    locationService.requestPermission()
                    notificationService.requestPermission()
                }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
                .tag(0)
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(1)
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .preferredColorScheme(.dark)
    }
}
