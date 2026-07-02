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
    @State private var showScore = false
    
    // Game State Variables
    @State private var buttonPosition: CGPoint = CGPoint(x: 200, y: 300)
    @State private var buttonColor: Color = .blue
    @State private var multiplier: Int = 1
    @State private var lastTapTime: Date = Date()
    @State private var isBonusBurst: Bool = false
    @State private var screenSize: CGSize = .zero
    
    // Timer References
    @State private var gameTimer: Timer?
    @State private var moveTimer: Timer?
    @State private var burstTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("\(count)").font(.system(size: 70))
                    Text("Combo: x\(multiplier)").foregroundColor(multiplier > 1 ? .orange : .gray)
                    Text("Time: \(timeLeft)s").foregroundColor(.gray)
                }
                .position(x: geometry.size.width / 2, y: 100)
                
                Button(action: {
                    handleTap()
                }) {
                    Text(isBonusBurst ? "DOUBLE!" : "Tap Me")
                        .padding(.horizontal, 80)
                        .padding(.vertical, 30)
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .position(buttonPosition)
                .animation(.easeInOut(duration: 0.3), value: buttonPosition)
                .disabled(timeLeft == 0)
            }
            .onAppear {
                screenSize = geometry.size
                startTimers(in: geometry.size)
            }
        }
        .sheet(isPresented: $showScore) {
            VStack(spacing: 20) {
                Text("Game Over!").font(.largeTitle)
                Text("Final Score: \(count)")
                
                Button("Play Again") {
                    resetGame()
                    startTimers(in: screenSize)
                    showScore = false
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 30)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
        }
    }
    
    func handleTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.5 {
            multiplier += 1
        } else {
            multiplier = 1
        }
        lastTapTime = now
        
        let points = (buttonColor == .green ? 5 : (buttonColor == .gray ? -2 : 1))
        let finalPoints = isBonusBurst ? points * 2 : points
        count += (finalPoints * multiplier)
    }
    
    func startTimers(in size: CGSize) {
        // Clear existing timers to prevent overlaps
        gameTimer?.invalidate()
        moveTimer?.invalidate()
        burstTimer?.invalidate()
        
        // Game Countdown
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                timer.invalidate()
                self.showScore = true
            }
        }
        
        // Movement & 3-second Color Change
        moveTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.buttonPosition = CGPoint(
                    x: CGFloat.random(in: 50...(size.width - 50)),
                    y: CGFloat.random(in: 150...(size.height - 100))
                )
                
                let random = Int.random(in: 1...10)
                self.buttonColor = (random == 1) ? .green : ((random == 2) ? .gray : .blue)
            } else {
                self.moveTimer?.invalidate()
            }
        }
        
        // Bonus Burst (Trigger at 5 seconds)
        burstTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.isBonusBurst = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isBonusBurst = false
            }
        }
    }
    
    func resetGame() {
        count = 0
        timeLeft = 10
        showScore = false
        multiplier = 1
    }
}

