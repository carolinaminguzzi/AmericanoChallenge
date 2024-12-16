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
    @State private var hapticTimer: Timer? = nil
    @GestureState private var isPressing = false // Stato per il gesto di pressione

    var body: some View {
        VStack {
            HStack {
                // Bottone Start/Stop con LongPressGesture
                Button(action: {
                    // Non fare nulla se il tocco non è stato mantenuto abbastanza a lungo
                }) {
                    Text(isRunning ? "Stop" : "Start")
                        .frame(width: 70, height: 70)
                        .background(isPressing ? Color.blue : (isRunning ? Color.green : Color.red))
                        .foregroundColor(isPressing ? Color.white : (isRunning ? Color.red : Color.green))
                        .clipShape(Circle())
                        .bold()
                        .scaleEffect(isPressing ? 1.2 : 1.0) // Aggiungi un effetto di ingrandimento quando si tiene premuto
                        
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 1.0) // 1 secondo per avviare il timer
                        .updating($isPressing) { value, state, _ in
                            state = value
                        }
                        .onEnded { _ in
                            if isRunning {
                                stopTimer()
                            } else {
                                startTimer()
                            }
                        }
                )

                Spacer()

                Button(action: {
                    generateHapticFeedback()
                    resetTimer()
                }) {
                    Text("Reset")
                        .frame(width: 70, height: 70)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(isRunning)
            }
            .padding([.leading, .trailing], 20)

            Spacer()

            Text(formatTime(timeElapsed))
                .font(.largeTitle)
                .padding()
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
    }

    func resetTimer() {
        timeElapsed = 0
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

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0

    var body: some View {
        VStack {
            Text("Timers")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            Spacer()

            // Picker for Hours, Minutes, Seconds con sfondo unico
            ZStack {
                // Background per l'intero contenitore dei picker
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2)) // Colore di sfondo grigio
                    .frame(height: 150) // Altezza del contenitore

                HStack(spacing: 0) {
                    VStack {
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0..<25, id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        Text("hours")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    VStack {
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        Text("min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    VStack {
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach(0..<60, id: \.self) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                        Text("sec")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding()
    

            // Buttons Start and Reset
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
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .font(.headline)
                }
                
                Button(action: {
                    generateHapticFeedback()
                    resetTimer()
                }) {
                    Text("Reset")
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .font(.headline)
                }
                .disabled(isRunning)
            }
            .padding(.bottom, 50)

            Spacer()
        }
    }

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
    }

    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}





struct ClockAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClockAppView()
    }
}
