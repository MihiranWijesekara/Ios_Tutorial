//
//  ContentView.swift
//  ios_development
//
//  Created by student5 on 2026-06-13.
//

import SwiftUI

struct ContentView: View {
    
    @State private var count: Int = 0
    // Fixed: @State must be capitalized
    @State private var timeLeft: Int = 10
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.system(size: 100))
                .padding(.bottom, 50)
            
            Button(action: {
                count += 1
            }) {
                Text("Tap Me")
                    .padding(.horizontal, 80)
                    .padding(.vertical, 30)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .disabled(timeLeft == 0)
            // Countdown text
            Text("Time remaining: \(timeLeft)")
                .font(.system(size: 20))
                .padding(.top, 20)
                .foregroundColor(.gray)
                .onAppear {
                    startTimer()
                }
        }
        .padding()
    }
    
    func startTimer() {
        // Fixed: Parameter name is 'withTimeInterval', not 'withTimerInterval'
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                // Fixed: Added missing closing parenthesis
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    ContentView()
}
