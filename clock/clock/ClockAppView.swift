//
//  ContentView.swift
//  clock
//
//  Created by carolina minguzzi on 13/12/24.
//

import SwiftUI
import UIKit
import AVFoundation


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
    @State private var rotationAngle: Double = 0 // Per il cerchio di caricamento
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0

    var body: some View {
        ZStack {
            // Sfondo verde per tutta la view
            Color.green
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Picker con numeri gialli quando selezionati
                ZStack {
                    HStack(spacing: 0) {
                        PickerColumn(title: "hours", range: 0..<25, selection: $selectedHours)
                        PickerColumn(title: "min", range: 0..<60, selection: $selectedMinutes)
                        PickerColumn(title: "sec", range: 0..<60, selection: $selectedSeconds)
                    }
                    .padding(.horizontal, 20)
                }
                .padding()

                Spacer()

                // Cerchio di caricamento visibile solo quando il timer è in esecuzione
                if isRunning {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 1)
                            .stroke(Color.yellow, lineWidth: 5)
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(.linear(duration: 1), value: rotationAngle) // Animazione fluida
                    }
                }

                // Pulsanti
                HStack(spacing: 60) {
                    Button(action: {
                        if isRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isRunning ? "Stop" : "Start")
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                            .clipShape(Circle())
                            .font(.headline)
                    }

                    Button(action: {
                        resetTimer()
                    }) {
                        Text("Reset")
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                            .clipShape(Circle())
                            .font(.headline)
                    }
                    .disabled(isRunning)
                }
                .padding(.bottom, 50)

                Spacer()
            }
        }
    }

    func startTimer() {
        timeRemaining = TimeInterval((selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds)
        isRunning = true
        rotationAngle = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                rotationAngle += 360 // Ruota il cerchio di 360° ogni secondo
                playSound()
                generateHapticFeedback()
            } else {
                stopTimer()
            }
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        selectedHours = 0
        selectedMinutes = 0
        selectedSeconds = 0
        timeRemaining = 0
        rotationAngle = 0
    }

    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func playSound() {
        let systemSoundID: SystemSoundID = 1053 // Suono di beep predefinito
        AudioServicesPlaySystemSound(systemSoundID)
    }
}

struct PickerColumn: View {
    let title: String
    let range: Range<Int>
    @Binding var selection: Int

    var body: some View {
        VStack {
            Picker(title, selection: $selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(value == selection ? Color.yellow : .primary) // Giallo per il valore selezionato
                        .scaleEffect(value == selection ? 1.0 : 1.2) // Rende il testo non selezionato più grande
                        .animation(.easeInOut(duration: 0.3), value: selection) // Animazione fluida
                        .frame(maxWidth: .infinity)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}



struct ClockAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClockAppView()
    }
}
