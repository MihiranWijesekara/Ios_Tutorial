import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var notificationService: NotificationService
    @StateObject private var statsVM = StatsVM()
    
    @AppStorage("notifications_enabled") private var notificationsEnabled = false
    @AppStorage("notification_hour") private var notificationHour = 9
    @AppStorage("notification_minute") private var notificationMinute = 0
    
    @State private var challengeTime = Date()
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Challenge Notifications")) {
                    Toggle("Enable Daily Challenge", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                notificationService.requestPermission()
                                notificationService.scheduleDailyChallengeNotification(at: challengeTime)
                            } else {
                                notificationService.cancelDailyChallengeNotification()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Challenge Time", selection: $challengeTime, displayedComponents: .hourAndMinute)
                            .onChange(of: challengeTime) { newTime in
                                saveTime(newDate: newTime)
                            }
                    }
                }
                
                Section(header: Text("Reset Application Data")) {
                    Button(role: .destructive, action: {
                        showResetConfirmation = true
                    }) {
                        Label("Reset All Stats", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .confirmationDialog(
                "Are you sure you want to reset all stats?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    statsVM.resetStats()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently clear your scores, high scores, map sessions, and reset your game data. This cannot be undone.")
            }
            .onAppear {
                loadTime()
                notificationService.checkPermissionStatus()
            }
        }
        
        
    }
    
    private func loadTime() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = notificationHour
        components.minute = notificationMinute
        challengeTime = Calendar.current.date(from: components) ?? Date()
    }
    
    private func saveTime(newDate: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
        notificationHour = components.hour ?? 9
        notificationMinute = components.minute ?? 0
        
        if notificationsEnabled {
            notificationService.scheduleDailyChallengeNotification(at: newDate)
        }
    }
}
