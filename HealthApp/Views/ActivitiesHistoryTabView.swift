
// NOTE: If the Navigation View did not function properly (i.e. as you scroll down, the "Activities History" text doesn't move along and stays there; or, the top navigation title bar doesn't appear), try to remove as many "padding()" inside the NavigationView as possible. This should resolve the problem. This behaviour is most likely due to a bug in SwiftUI: the background color is currently set by ".background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))" as suggested in this solution: https://www.hackingwithswift.com/forums/swiftui/set-background-of-scrollview-in-navigationview/2055


import SwiftUI

struct ActivitiesHistoryTabView: View {

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
                        
                VStack(alignment: .center) {
                    
                    
                    // STEP COUNT SECTION
                    if !stepsWeeks.isEmpty {
                        
                        Text("Highlights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .offset(x: -135, y: 10)
                        
                        StepsChartView(stepsWeeks: stepsWeeks)
                            .cornerRadius(15)
                        
                    }
                    
                    // HEART RATE SECTION
                    if !heartRates.isEmpty {
                        HeartRateChartView(heartRates: heartRates)
                            .cornerRadius(15)

                        Spacer()

                        Text("\nWhat other information would you be interested in seeing here? Send us an email with a description. \nWe are here for you! 😊💪🏻\n")
                            .foregroundColor(Color(.systemGray))
                            .frame(width: 380)

                        Button(action: {
                            EmailHelper.shared.sendEmail(subject: "Request", body: "", to: "ko.sakuma.20@ucl.ac.uk")
                        }) {
                            Text("Send a Request")
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(.systemBlue), lineWidth: 1)
                                )

                        }

                        Spacer()
                        
                    }
                    
                }
          
            }
            .navigationTitle("Activities History")
            .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add Helper info here
                        print("Remember to Add Helper info!")
                    }, label: {
                        Image(systemName: "questionmark.circle")
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


//// Reference: https://stackoverflow.com/questions/56923397/how-change-background-color-if-using-navigationview-in-swiftui
//extension UINavigationController {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//
//    let standard = UINavigationBarAppearance()
//    standard.backgroundColor = .secondarySystemBackground //When you scroll or you have title (small one)
//
//    let compact = UINavigationBarAppearance()
//    compact.backgroundColor = .secondarySystemBackground //compact-height
//
//    let scrollEdge = UINavigationBarAppearance()
//    scrollEdge.backgroundColor = .secondarySystemBackground //When you have large title
//
//    navigationBar.standardAppearance = standard
//    navigationBar.compactAppearance = compact
//    navigationBar.scrollEdgeAppearance = scrollEdge
// }
//}

struct TrackMeHome_Previews: PreviewProvider {

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

        ActivitiesHistoryTabView(steps: steps, heartRates: heartRates)

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




