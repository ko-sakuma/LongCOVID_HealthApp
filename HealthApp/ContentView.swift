//
//  ContentView.swift
//  HealthApp
//
//  Created by Ko Sakuma on 21/06/2021.
//

import SwiftUI
import HealthKit

struct ContentView: View {

    // REFERENCES
    @State private var steps: [Step] = [Step]()
    @State private var heartRates: [HeartRate] = [HeartRate]()

    // MARK: - UPDATE UI FROM STATISTICS (STEPS)
    private func updateUIFromStepCountStatistics(_ statisticsCollection: HKStatisticsCollection) {

        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let endDate = Date()

        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, _) in

            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            steps.append(step)

        }
    }

    // MARK: - UPDATE UI FROM STATISTICS (HEART RATE)
    private func updateUIFromHeartRateSamples(_ samples: [HKSample]) {
        heartRates = samples.compactMap { HeartRate(sample: $0) }
    }

    // CREATE THE VIEW OF HOME: SETTING TrackMe AS DEFAULT
    @State private var selection: Tab = .trackMe

    enum Tab {
        case trackMe
        case remindMe
//        case aboutMe
    }

    var body: some View {

        TabView(selection: $selection) {
            TrackMeHome(steps: steps, heartRates: heartRates)
                .tabItem {
                    Label("Track", systemImage: "waveform.path.ecg")

                }
                .tag(Tab.trackMe)

            TaskListView()
                .tabItem {
                    Label("Remind", systemImage: "bell")
                }
                .tag(Tab.remindMe)

//            TrackMeHome(steps: steps, heartRates: heartRates) // Wrong function for now.
//                .tabItem {
//                    Label("Settings", systemImage: "person.crop.circle")
//                }
//                .tag(Tab.aboutMe)

        }
        .onAppear {
            HealthStore.shared.requestAuthorization { success in
                if success {
                    HealthStore.shared.calculateSteps { statisticsCollection in
                        if let statisticsCollection = statisticsCollection {
                            updateUIFromStepCountStatistics(statisticsCollection)
                        }
                    }
                    HealthStore.shared.calculateHeartRate(completion: updateUIFromHeartRateSamples)
                }
            }
        }
    }
 }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
