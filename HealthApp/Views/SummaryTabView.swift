
import SwiftUI

struct SummaryTabView: View {

    // MARK: - Environment
    @Environment(\.calendar) private var calendar // Get the user's default calendar preference (week starts from Mon/Sun)
    
    // MARK: - State
    @State var showStepsChartView = false

    // MARK: - Type definitions
    let stepsWeeks: [StepsWeek]
    let heartRates: [HeartRate]
    
    // MARK: - Body
    var body: some View {
        

        NavigationView {
            ScrollView {

                VStack(alignment: .leading) {
//
//                        Button(action: { showStepsChartView = true} ) {
//                                                    VStack (alignment: .leading){
//
//                                                        HStack (alignment: .top) {
//                                                            Image(systemName: "flame.fill")
//
//                                                            Text("Your Steps")
//                                                                .font(.title2)
//                                                                .fontWeight(.bold)
//
//                                                        }
//
//                                                        Divider()
//
//                                                        StepsChartCeilingText()
//
//                                                    }
//                                                    .frame(minWidth: .infinity, minHeight: .infinity)
//
//                                                }
//                                                .sheet(isPresented: $showStepsChartView) { StepsChartView(steps: steps) }
//                                                .foregroundColor(Color(.systemPink))
//                                                .background(Color(.systemGray6)) // background of the rectangle
//                                                .cornerRadius(8)

                        
                        
//                       // STEP COUNT SECTION
                        if !stepsWeeks.isEmpty {
                            StepsChartView(stepsWeeks: stepsWeeks)
                        }
                        
                 
                        
                        if !heartRates.isEmpty {
                            HeartRateChartView(heartRates: heartRates)
                        }
              
                    
                    }
                    .cornerRadius(10)
                    .padding(10)

                }
                .navigationTitle("Summary")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // TODO: Add JSON things here, when ready!
                            print("Remember to Add Helper info!")
                        }, label: {
                            Text("Need Help?")
                        })
                    }
                }

        }
    }
    

    // MARK: - Initialiser that groups Steps & Heart Rate by day and week
    init(steps: [Step], heartRates: [HeartRate]) {
        // Group daily steps data by week
        
        var stepsWeeks = [StepsWeek]()
        var weekSteps = [Step]() // create an empty array, which I can later insert max 7 days worth of data
        
        let calendar = Calendar.current
        
        for step in steps {
            // extract the weekday (monday..friday)
            if let weekday = calendar.dateComponents([.weekday], from: step.date).weekday,
               weekday != calendar.firstWeekday { // Detect First week day
                // if not weekday then append (weekend)
                weekSteps.append(step)
            } else {
                // if it is the first day of the week, then just build it up
                if !weekSteps.isEmpty {
                    stepsWeeks.append(StepsWeek(steps: weekSteps))
                    weekSteps.removeAll()
                }
                weekSteps.append(step) //new
            }
        }
        // Add the last one
        if !weekSteps.isEmpty {
            stepsWeeks.append(StepsWeek(steps: weekSteps))
        }
        
        self.stepsWeeks = stepsWeeks
        
        self.heartRates = heartRates
    }
}

extension Date {
    func startOfWeek(using calendar: Calendar) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}


struct TrackMeHome_Previews: PreviewProvider {
//    struct Container: View {
//        @State private var selectedTab: Int = 1000
//        var body: some View {
//            TabView(selection: $selectedTab) {
//                ForEach(Array(0..<2000), id: \.self) { number in
//                    Text(String(describing: number))
//                        .tabItem { Text(String(describing: number)) }
//                        .id(number)
//                }
//            }
//            .tabViewStyle(PageTabViewStyle())
//        }
//    }

    static var previews: some View {

    let now = Date()
            let startOfPreviousWeek = now.addingTimeInterval(-60*60*24*7).startOfWeek(using: .autoupdatingCurrent)

            let heartRates: [HeartRate] = (0..<2).flatMap { weekOffset in
                (0..<7).flatMap { dayOffset -> [HeartRate] in
                    let day = startOfPreviousWeek.addingTimeInterval( (Double(7*weekOffset) + Double(dayOffset))*60*60*24)
                    return (0..<3).map { sampleIndex in
                        HeartRate(count: sampleIndex * 50, date: day)
                    }
                }
            }

            let tomorrow = now.addingTimeInterval(60*60*24)
            let dayAfter = tomorrow.addingTimeInterval(60*60*24)
            let steps = [
                        Step(count: 3452, date: Date()),
                        Step(count: 1234, date: Date()),
                        Step(count: 1553, date: Date()),
                        Step(count: 123, date: Date()),
                        Step(count: 1223, date: Date()),
                        Step(count: 5223, date: Date()),
                        Step(count: 12023, date: Date())

                   ]

//        let heartRates = [
//                    HeartRate(count: 80, date: Date()),
//                    HeartRate(count: 92, date: Date()),
//                    HeartRate(count: 105, date: Date()),
//                    HeartRate(count: 112, date: Date()),
//                    HeartRate(count: 180, date: Date()),
//                    HeartRate(count: 200, date: tomorrow),
//                    HeartRate(count: 102, date: dayAfter)
//
//        ]

        SummaryTabView(steps: steps, heartRates: heartRates)

    }
}



// COMMENT OUT UNTIL THE averateHeartRates formulate is corrected.
//                        Text("Your average heart rate this week:  \(averageHeartRates)")
//                            .font(.subheadline)
//                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//                            .padding(.top, 3.0)
//                    }
//                    .padding(.bottom, 20.0)

// ANOTHER STUFF
//                        Text("Your heart rate range this week: \(minHeartRates) - \(maxHeartRates)")
//                            .font(.subheadline)
//                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//                            .padding(.top, 20.0)










