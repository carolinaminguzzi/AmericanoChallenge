//
//  ContentView.swift
//  clock
//
//  Created by carolina minguzzi on 13/12/24.
//

import SwiftUI
import UIKit


struct ClockAppView: View {
    var body: some View {
        TabView {
            WorldClockView()
                .tabItem {
                    Label("World Clock", systemImage: "globe")
                }

            AlarmView()
                .tabItem {
                    Label("Alarm", systemImage: "alarm")
                }

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

struct WorldClockView: View {
    @State private var cities: [String] = [
        "New York", "London", "Tokyo", "Paris", "Sydney"
    ] // Array dinamico delle città

    var body: some View {
        NavigationView {
            List {
                ForEach(cities, id: \.self) { city in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city)
                                .font(.headline)
                            Text("Time Zone")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("12:34 PM")
                            .font(.title3)
                    }
                }
                .onDelete(perform: deleteCity) // Permette l'eliminazione
            }
            .navigationTitle("World Clock")
            .toolbar {
                EditButton() // Bottone per attivare/disattivare la modalità di modifica
            }
        }
    }

    // Funzione per eliminare una città
    private func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

struct AlarmView: View {
    @State private var alarms: [Bool] = Array(repeating: true, count: 5) // Stato per le sveglie

    var body: some View {
        NavigationView {
            List {
                ForEach(alarms.indices, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Alarm \(index + 1)")
                                .font(.headline)
                            Text("Repeat")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Toggle("", isOn: $alarms[index]) // Collega ogni toggle al suo stato
                            .labelsHidden()
                    }
                
                }
                .onDelete(perform: deleteAlarm) // Permette l'eliminazione
            }
            .navigationTitle("Alarm")
            .toolbar {
                EditButton() // Bottone per attivare/disattivare la modalità di modifica
            }
        }
    }
    
    

    // Funzione per eliminare una sveglia
    private func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    
}



struct StopwatchView: View {
    @State private var isRunning = false
    @State private var timeElapsed: TimeInterval = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Text(formatTime(timeElapsed))
                .font(.largeTitle)
                .padding()

            HStack {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "Stop" : "Start")
                        .frame(width: 70, height: 70)
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

            
                Button("Reset") {
                    resetTimer()
                }
                .frame(width: 70, height: 70)
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .disabled(isRunning)
        
            }
            .padding()
        }
    }

    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        timeElapsed = 0
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}


struct TimerView: View {
    @State private var timeRemaining: TimeInterval = 60
    @State private var isRunning = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Text(formatTime(timeRemaining))
                .font(.largeTitle)
                .padding()

            HStack {
                Button(action: {
                    provideHapticFeedback()
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "Pause" : "Start")
                        .frame(width: 70, height: 70)
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                Button("Reset") {
                    provideHapticFeedback()
                    resetTimer()
                }
                .frame(width: 70, height: 70)
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .disabled(isRunning)
            }
            .padding()
        }
    }

    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
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
        timeRemaining = 60
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

struct ClockAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClockAppView()
    }
}
