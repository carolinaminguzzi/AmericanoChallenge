//
//  ContentView.swift
//  clock
//
//  Created by carolina minguzzi on 13/12/24.
//

import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox




struct ClockAppView: View {
    

    init() {
        // Set the color of the selected tab item to yellow
        UITabBar.appearance().tintColor = UIColor.systemPink
        // Set the unselected tab item color (optional)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        
        //Cacca pupu
        
    }
    
    var body: some View {
        TabView {
            
            TimerView()
            .tabItem {
                Label("Timer", systemImage: "timer")
            }
            
            StopwatchView()
            .tabItem {
                Label("Stopwatch", systemImage: "stopwatch")
            }

        }
    }
}




struct TimerView: View {
    @State private var timeRemaining: TimeInterval = 0
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    @State private var hapticTimer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer?

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0

    @State private var isPulsatingLeft = false // Controls alternating pulsation

    var body: some View {
        ZStack {
            Color.green
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                if isRunning {
                    // Buttons move to the center
                    HStack(spacing: 50) {
                        Button(action: {
                            stopTimer()
                        }) {
                            Text("")
                                .frame(width: 100, height: 100)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .font(.headline)
                                .scaleEffect(isPulsatingLeft ? 1.2 : 1.0) // Pulsate
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isPulsatingLeft)
                        }

                        Button(action: {
                            resetTimer()
                        }) {
                            Text("")
                                .frame(width: 100, height: 100)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .font(.headline)
                                .scaleEffect(isPulsatingLeft ? 1.0 : 1.2) // Alternate pulsate
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isPulsatingLeft)
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        startPulsatingAnimation()
                        startHapticAndSoundFeedback()
                    }
                    .onDisappear {
                        stopHapticAndSoundFeedback()
                    }
                } else {
                    // Time Picker when timer is not running
                    VStack {
                        HStack(spacing: 0) {
                            PickerColumn(title: "sec", range: 0..<59, selection: $selectedSeconds)
                            PickerColumn(title: "hours", range: 0..<24, selection: $selectedHours)
                            PickerColumn(title: "min", range: 0..<59, selection: $selectedMinutes)
                        }
                        .padding()

                        HStack(spacing: 50) {
                            // Start Button
                            Button(action: {
                                startTimer()
                            }) {
                                Text("")
                                    .frame(width: 70, height: 70)
                                    .background(Color.yellow.opacity(0.6))
                                    .foregroundColor(.black)
                                    .clipShape(Circle())
                                    .font(.headline)
                            }

                            // Reset Button
                            Button(action: {
                                resetTimer()
                            }) {
                                Text("")
                                    .frame(width: 100, height: 100)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .clipShape(Circle())
                                    .font(.headline)
                            }
                        }
                        .animation(.easeInOut(duration: 0.5), value: isRunning)
                    }
                }

                Spacer()
            }
            .animation(.easeInOut(duration: 0.5), value: isRunning)
        }
    }

    // Start Timer
    func startTimer() {
        timeRemaining = TimeInterval((selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds)
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }

    // Stop Timer
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        stopHapticAndSoundFeedback()
    }

    // Reset Timer
    func resetTimer() {
        stopTimer()
        selectedHours = 0
        selectedMinutes = 0
        selectedSeconds = 0
        timeRemaining = 0
    }

    // Pulsating Animation
    func startPulsatingAnimation() {
        isPulsatingLeft = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPulsatingLeft.toggle()
        }
    }

    // Haptic and Sound Feedback
    func startHapticAndSoundFeedback() {
        let hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            hapticGenerator.impactOccurred()
            playBuiltInSound()
        }
    }

    func stopHapticAndSoundFeedback() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        audioPlayer?.stop()
    }

    // Play Tick Sound
    func playBuiltInSound() {
        AudioServicesPlaySystemSound(1057) // "Mail Sent" sound
    }
    
}

struct PickerColumn: View {
    let title: String
    let range: Range<Int>
    @Binding var selection: Int

    // Computed property: Shuffle the numbers in the range
    private var shuffledValues: [Int] {
        Array(range).shuffled()
    }

    var body: some View {
        VStack {
            Picker(title, selection: $selection) {
                ForEach(shuffledValues, id: \.self) { value in
                    Text("\(value)")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Text(title)
                .font(.subheadline)
                .foregroundColor(.yellow)
        }
    }
}



struct ClockAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClockAppView()
    }
}
