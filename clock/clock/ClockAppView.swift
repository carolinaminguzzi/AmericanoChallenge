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
    var body: some View {
        TabView {

            StopwatchView()
                .tabItem {
                    Label("Stopwatch", systemImage: "stopwatch")
                }

            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
        }
    
    }
    
}


struct StopwatchView: View {
    @State private var isRunning = false
    @State private var timeElapsed: TimeInterval = 0 // Tempo conteggiato in background
    @State private var displayedTime: TimeInterval = 0 // Tempo mostrato all'utente
    @State private var timer: Timer? = nil
    @State private var hapticTimer: Timer? = nil
    @State private var isButtonPressed = false // Stato per controllare l'ingrandimento del bottone

    var body: some View {
        ZStack {
            Color.purple
                .edgesIgnoringSafeArea(.all) // Sfondo viola

            // Timer centrato nella vista
            VStack {
                Spacer()

                Text(formatTime(displayedTime)) // Mostra solo il tempo fermato
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.blue)

                Spacer()
            }

            // Bottone Reset in alto a sinistra
            VStack {
                HStack {
                    Button(action: {
                        generateHapticFeedback()
                        resetTimer()
                    }) {
                        Text("Reset")
                            .frame(width: 70, height: 70)
                            .background(Color.blue)
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                            .font(.headline)
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)

                    Spacer()
                }

                Spacer()
            }

            // Bottone Start/Stop in basso a sinistra
            VStack {
                Spacer()

                HStack {
                    Button(action: {
                        isButtonPressed = true
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                            isButtonPressed = false
                        }
                        if isRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isRunning ? "Stop" : "Start")
                            .frame(width: 70, height: 70)
                            .background(isRunning ? Color.blue : Color.blue)
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                            .bold()
                            .scaleEffect(isButtonPressed ? 1.2 : 1.0) // Ingrandisce quando premuto
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 20)

                    Spacer()
                }
            }
        }
    }

    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
        startHapticFeedbackLoop()
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        stopHapticFeedbackLoop()

        // Aggiorna il valore mostrato quando si preme "Stop"
        displayedTime = timeElapsed
    }

    func resetTimer() {
        timeElapsed = 0
        displayedTime = 0
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func startHapticFeedbackLoop() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            generateHapticFeedback()
        }
    }

    func stopHapticFeedbackLoop() {
        hapticTimer?.invalidate()
        hapticTimer = nil
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
                            PickerColumn(title: "sec", range: 0..<60, selection: $selectedSeconds)
                            PickerColumn(title: "hours", range: 0..<25, selection: $selectedHours)
                            PickerColumn(title: "min", range: 0..<60, selection: $selectedMinutes)
                        }
                        .padding()

                        HStack(spacing: 50) {
                            // Start Button
                            Button(action: {
                                startTimer()
                            }) {
                                Text("")
                                    .frame(width: 100, height: 100)
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
        let hapticGenerator = UIImpactFeedbackGenerator(style: .rigid)
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            hapticGenerator.impactOccurred()
            playTickSound()
        }
    }

    func stopHapticAndSoundFeedback() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        audioPlayer?.stop()
    }

    // Play Tick Sound
    func playTickSound() {
        guard let soundURL = Bundle.main.url(forResource: "tick", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
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
                        .foregroundColor(.black)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}



struct ClockAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClockAppView()
    }
}
