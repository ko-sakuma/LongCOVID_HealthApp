
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
                        
                        Spacer()
                        
                        if !heartRates.isEmpty {
                            HeartRateChartView(heartRates: heartRates)
                        }
                    }
//                    .background(Color(.white))
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


struct HeartRateChartView: View {
    
    let heartRateDateGroups: [HeartRateDateGroup]
    @State var selectedHeartRateDay: Int
    
    init(heartRates: [HeartRate]) {
        // Group heart rate
        if heartRates.isEmpty {
            self.heartRateDateGroups = []
            self.weeks = []
            maxHeartRates = Int.min
            minHeartRates = Int.max
            min = 0
            max = 0
        } else {
            var groups = [HeartRateDateGroup]()
            var date = heartRates[0].date
            let calendar = Calendar.current

            let parameterHeartRates = heartRates
            var heartRates: [HeartRate] = []

            for heartRate in parameterHeartRates {
                if calendar.isDate(date, inSameDayAs: heartRate.date) {
                    heartRates.append(heartRate)
                } else {
                    // Created new group based on the existing data
                    let group = HeartRateDateGroup(date: date, heartRates: heartRates)
                    groups.append(group)

                    // Clean up
                    heartRates.removeAll()
                    date = heartRate.date

                    // Add the new record
                    heartRates.append(heartRate)
                    
                }
            }

            // Close the last group as well
            let group = HeartRateDateGroup(date: date, heartRates: heartRates)
            groups.append(group)
            self.heartRateDateGroups = groups
            let weeks  = Dictionary(grouping: groups) { group in
                Int(group.date.startOfWeek(using: calendar).timeIntervalSince1970) // * 1000 (miliseconds)
            }
            .sorted(by: { $0.key < $1.key })
            self.weeks = weeks
            
            // Calculate the min, max, ...
            maxHeartRates = heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) })
            minHeartRates = heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) })
            min = CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0)
            max =  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0)
        }
        
        ySpan = max - min
        yFactor = ((hrGraphHeight - sampleSize) / ySpan)
        
        selectedHeartRateDay = weeks.last?.key ?? 0
    }

    // MARK: - Heart Rate Chart related
    private var weeks: [(key: Int, value: [HeartRateDateGroup])]

    let maxHeartRates: Int
    let minHeartRates: Int

    let hrGraphHeight: CGFloat = 280

    let sampleSize: CGFloat = 40

    let min: CGFloat
    let max: CGFloat

    let ySpan: CGFloat
    let yFactor: CGFloat
    
    var body: some View {
        VStack {
            // HEART RATE SECTION
            heartRateChartTitle
            Spacer()
            heartRateChartDescription
            heartRateChart
//            heartRateChartCeilingText
        }
    }

    var heartRateChartTitle: some View {
        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
            .font(.title2)
            .foregroundColor(Color(.systemPink))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .position(.init(x: 80, y: 30))
    }
    
    var heartRateChartDescription: some View {
        Text("Green means you are meeting your heart rate goal! Your current ceiling is 120.")
            .foregroundColor(Color(.systemGray))
            .lineLimit(5)
            .multilineTextAlignment(.leading)
            .frame(width: 380, height: 100)
    }
    
    var heartRateChart: some View {

        HStack {
            
            VStack {
                Text("max")
                Divider()
                Text("min")
            }
            .offset(y: -115)
            .frame(width: 40)
            
            TabView(selection: $selectedHeartRateDay) {
                ForEach(weeks, id: \.key) { (date, week) in
                    heartRateChartWeek(week)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
            
        }
    }

        
    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
        
        HStack(alignment: .bottom) {
            
            ForEach(week, id: \.id) { group in
                VStack {
                    
                    Text(String(describing: group.maxHR))
                        .foregroundColor(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
                        .fontWeight(.bold)
                        // TODO: replace 120 with actual threshold set by user
                        .offset(y: 40)
                        
                    Divider()
                        .offset(y: 40)
                    
                    Text(String(describing: group.minHR)) // minHR here
                        .foregroundColor(group.minHR > 120 ? Color(.systemPink) :Color(.systemGreen))
                        .fontWeight(.bold)
                        .offset(y: 40)
                        // TODO: replace 120 with actual threshold set by user

                    
                    ZStack(alignment: .bottom) {

                        ForEach(group.ranges, id: \.id) { heartRate in
                            let yValue = (CGFloat(heartRate.averageHR) - min) * yFactor
                            let height = CGFloat(heartRate.deltaHR) * yFactor
                            RoundedRectangle(cornerRadius: sampleSize/2)
                                .fill(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
//                                .overlay(Text(String(describing: heartRate.count))) // KEEP
                                .offset(x: 0, y: (height / 2) - yValue )
                                .frame(width: sampleSize, height: height)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }

                    }
                    .padding(.vertical, sampleSize/2)
                    .offset(y: -40)
                    .frame(height: hrGraphHeight)
                    

                    Text("\(group.date, formatter: Self.dateFormatter)")
                        .offset(y: -40)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()

    var heartRateChartCeilingText: some View {
        Text("Your Heart Rate ceiling this week: 70")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
            .padding(.top, 20.0)
    }

}


extension Date {
    func startOfWeek(using calendar: Calendar) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}



// MARK: - STEPS related
struct StepsChartView: View {
    
    let stepsWeeks: [StepsWeek]
    
    var body: some View {
        StepsChartTitle()
        StepsChart(stepsWeeks: stepsWeeks)
//        StepsChartCeilingText()
    }
    
    
}


struct StepsChartTitle:  View {

    var body: some View {
        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
            .font(.title2)
            .foregroundColor(Color(.systemRed))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
        
        Text("Try to keep your daily steps below 2000😊 Green bar means you are meeting your daily goal!")
            .foregroundColor(Color(.systemGray))
            .lineLimit(5)
            .multilineTextAlignment(.leading)
            .frame(width: 390, height: 100)
    }
}

struct StepsChart: View {
    
    // MARK: - State
    @State var selectedID: Int
    
    // MARK: - Type definitions
    let stepsWeeks: [StepsWeek]
    
    init(stepsWeeks: [StepsWeek]) {
        self.stepsWeeks = stepsWeeks
        self.selectedID = stepsWeeks.last!.id
    }
    
    // MARK: - Body
    var body: some View {
        
        HStack {
            VStack {
                Divider()
                Text("Count")
                    .font(.caption)
                Divider()
            }
            .offset(y: -133)
            .frame(width: 40)
            
            TabView(selection: $selectedID) {
                ForEach(stepsWeeks, id: \.id) { (week) in
                    StepsChartWeek(steps: week.steps).tag(week.id)
                }
            }
            .tabViewStyle(PageTabViewStyle())
    //            .frame(width: 390, height: 300)
            .frame(height: 300)
            
        }
    }
}
    

struct StepsChartWeek: View {
    
    let steps: [Step]
    let graphHeight: CGFloat = 235 //was 260 
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    var body: some View {
        let max = CGFloat(steps.map(\.count).max() ?? 0)
        let min: CGFloat = 0
        let ySpan: CGFloat = max - min
        let yFactor: CGFloat = graphHeight / ySpan
        
        // COMPLETED STEP GRAPH VIEW FOR A WEEK
        HStack(alignment: .lastTextBaseline) {

            ForEach(steps, id: \.id) { step in
                    let yValue = CGFloat(step.count) * yFactor
                        
                        VStack {
                            
                            Divider()
                              
                            
                            Text("\(step.count)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
//                                .lineLimit(nil)
//                                .fixedSize(horizontal: false, vertical: true)
                             
                            Divider()
                               
                    
                            RoundedRectangle(cornerRadius: 10)
                                .fill(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
//                                .frame(height: CGFloat(yValue))
                                .frame(height: CGFloat(yValue))
//                                .overlay(
//                                    Text("\(step.count)")
//                                        .font(.caption)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
//                                        .offset(y: -20),
//                                    alignment: .top
//                                )
                                .frame(height: graphHeight, alignment: .bottom)

                            Text("\(step.date, formatter: Self.dateFormatter)")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                        }
                        .frame(width: 40)
                    
                }


        }
        .padding(.vertical, 30)
        
        
    }
}
    


struct StepsChartCeilingText: View {

    var body: some View {
        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemGray))
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










