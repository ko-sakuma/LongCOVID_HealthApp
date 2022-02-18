
import SwiftUI
import HealthKit

struct ContentView: View {

    // MARK: - Environment
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    // MARK: - State
    @State private var steps: [Step] = [Step]()
    @State private var heartRates: [HeartRate] = [HeartRate]()
    @State private var selection: Tab = .activitiesHistory

    // MARK: - Type definitions
    enum Tab {
        case activitiesHistory
        case goals
        case symptomsHistoryTab
        case updateMeTab
    }

    // MARK: - Body
    var body: some View {

        TabView(selection: $selection) {
            
            GoalsTabView()
                .tabItem { Label("Goals", systemImage: "house.fill") }
                .tag(Tab.goals)

            ActivitiesHistoryTabView(steps: steps, heartRates: heartRates)
                .tabItem { Label("Activities History", systemImage: "waveform.path.ecg") }
                .tag(Tab.activitiesHistory)

            SymptomHistoryTabView()
                .tabItem {
                    Label("Symptoms History", systemImage: "text.badge.plus")

                }
                .tag(Tab.symptomsHistoryTab)
                
            
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.updateMeTab)
        }
        .onAppear {
            HealthStore.shared.requestAuthorization { success in
                if success {
                    HealthStore.shared.calculateSteps { statisticsCollection in
                        DispatchQueue.main.async {
                            if let statisticsCollection = statisticsCollection {
                                updateUIFromStepCountStatistics(statisticsCollection)
                            }
                        }
                    }
                    HealthStore.shared.calculateHeartRate { hrSamples in
                        DispatchQueue.main.async {
                            updateUIFromHeartRateSamples(hrSamples)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - UPDATE UI FROM STATISTICS (STEPS)
    private func updateUIFromStepCountStatistics(_ statisticsCollection: HKStatisticsCollection) {

        let startDate = Calendar.current.date(byAdding: .day, value: -730, to: Date())!   // fetching 2 years back (730 days)
        let endDate = Date()

        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, _) in
            DispatchQueue.main.async {
                let count = statistics.sumQuantity()?.doubleValue(for: .count())
                let step = Step(count: Int(count ?? 0), date: statistics.startDate)
                steps.append(step)
            }
        }
    }

    // MARK: - UPDATE UI FROM STATISTICS (HEART RATE)
    private func updateUIFromHeartRateSamples(_ samples: [HKSample]) {
        heartRates = samples.compactMap { HeartRate(sample: $0) }
    }

 }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SymptomJSONManager())
    }
}
