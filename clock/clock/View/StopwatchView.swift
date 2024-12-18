//
//  StopwatchView.swift
//  clock
//
//  Created by carolina minguzzi on 18/12/24.
//
import SwiftUI
import AudioToolbox

struct StopwatchView: View {
    @State private var timeElapsed: TimeInterval = 0 // Elapsed time
    @State private var displayedTime: TimeInterval = 0 // Displayed time
    @State private var timer: Timer? = nil
    @State private var isRunning = false // Tracks timer state
    @State private var laps: [String] = [] // Stores laps

    var body: some View {
        ZStack {
            Color.purple.edgesIgnoringSafeArea(.all)

            VStack {
                // Timer Display in the center
                Text(formatTime(displayedTime))
                    .font(.system(size: 35, weight: .regular))
                    .foregroundColor(.blue)
                    .padding()

                // Buttons Row right under the timer
                HStack(spacing: 50) {
                    // Reset Button
                    Button(action: {
                        resetTimer()
                        playSoundFeedback(for: .correctAction) // Play "correct action" sound
                    }) {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                    }
                    .onTapGesture {
                        if isRunning {
                            stopTimer()
                            generateHapticFeedback(style: .light)
                            
                        }
                    }

                    // Lap/Stop Button
                    ZStack {
                        Image(systemName: "arrowtriangle.up.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                    .onTapGesture {
                        playSoundFeedback(for: .tickSound) // Play tick sound
                        if isRunning {
                            recordLap()
                            
                        }
                    }
                    .onLongPressGesture(minimumDuration: 1) {
                        if isRunning {
                            stopTimer()
                            generateHapticFeedback(style: .heavy)
                        }
                    }

                    // Start Button
                    Button(action: {
                        startTimer()
                        playSoundFeedback(for: .wrongAction) // Play "wrong action" sound
                    }) {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .padding()

                Spacer()

                // Laps Section with ScrollView
                if !laps.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Laps:")
                            .font(.headline)
                            .foregroundColor(.blue)

                        ScrollView {
                            ForEach(Array(laps.enumerated()), id: \.offset) { index, lap in
                                Text("Lap \(index + 1): \(lap)")
                                    .font(.body)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxHeight: 200) // Limit scrollable height
                    }
                    .padding(.horizontal)
                }
            }
            .padding(120)
        }
        
    }
    
    func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }


    // MARK: - Timer Functions
    func startTimer() {
        if !isRunning {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                displayedTime += 0.1
                
                //displayedTime = timeElapsed
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
        timeElapsed = 0
        displayedTime = 0
        laps.removeAll()
    }

    func recordLap() {
        let lapTime = formatTime(timeElapsed)
        laps.append(lapTime)
    }

    // MARK: - Time Formatting
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - floor(time)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    // MARK: - Sound Feedback
    enum SoundType {
        case tickSound, wrongAction, correctAction
    }

    func playSoundFeedback(for type: SoundType) {
        let soundID: SystemSoundID
        switch type {
        case .tickSound:
            soundID = 1104 // Camera shutter-like tick
        case .wrongAction:
            soundID = 1053 // Wrong action sound
        case .correctAction:
            soundID = 1057 // Mail sent sound
        }
        AudioServicesPlaySystemSound(soundID)
    }
}

#Preview {
    StopwatchView()
}
