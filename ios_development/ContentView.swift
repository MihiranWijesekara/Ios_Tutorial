//
//  ContentView.swift
//  ios_development
//
//  Created by student5 on 2026-06-13.
//

import SwiftUI

struct ContentView: View {
    @State private var count: Int = 0
    @State private var timeLeft: Int = 10
    @State private var timer: Timer?
    @State private var showScore = false
    
    // Position state
    @State private var buttonPosition: CGPoint = CGPoint(x: 200, y: 300)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("\(count)")
                        .font(.system(size: 70))
                    
                    Text("Time remaining: \(timeLeft)")
                        .foregroundColor(.gray)
                }
                .position(x: geometry.size.width / 2, y: 100)
                
                // The moving button
                Button(action: {
                    count += 1
                }) {
                    Text("Tap Me")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .position(buttonPosition)
                // Smooth animation for position changes
                .animation(.easeInOut(duration: 0.5), value: buttonPosition)
                .disabled(timeLeft == 0)
            }
            .onAppear {
                startTimer(in: geometry.size)
            }
        }
        .sheet(isPresented: $showScore) {
            // ... your existing sheet code ...
            VStack(spacing: 20) {
                Text("Game Over!")
                Text("Final Score: \(count)")
                Button("Play Again") { resetGame() }
            }
        }
    }
    
    func startTimer(in size: CGSize) {
        // Timer for game countdown
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
                showScore = true
            }
        }
        
        // Timer for button movement every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if timeLeft > 0 {
                let randomX = CGFloat.random(in: 50...(size.width - 50))
                let randomY = CGFloat.random(in: 150...(size.height - 100))
                buttonPosition = CGPoint(x: randomX, y: randomY)
            }
        }
    }
    
    func resetGame() {
        count = 0
        timeLeft = 10
        showScore = false
        // Re-start timer logic here
    }
}
