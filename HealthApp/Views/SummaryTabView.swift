
import SwiftUI

struct SummaryTabView: View {

    // Get the user's default calendar preference (week starts from Mon/Sun)
    @Environment(\.calendar) private var calendar
    @State private var selectedHeartRateDay: Date = .distantPast  //play around with this to align date order
    
    @State var showStepsChartView = false

    let steps: [Step]
    let heartRates: [HeartRate]
    let heartRateDateGroups: [HeartRateDateGroup]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()


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
                        StepsChartView(steps: steps)
                        
//                        StepsChartTitle()
//                        StepsChart(steps: steps)
//                        StepsChartCeilingText()
//
                        Spacer()
                        
                        // HEART RATE SECTION
                        heartRateChartTitle
                        Spacer()
                        heartRateChartDescription
                        heartRateChart
                        heartRateChartCeilingText
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
                            print("Remember to Add JSONSymptoms functions here!")
                        }, label: {
                            Text("Add Symptom")
                        })
                    }
                }

        }
        .onFirstAppear {
            DispatchQueue.main.async {
                selectedHeartRateDay = weeks.last?.key ?? .distantPast
            }
        }
    }

    // MARK: - Initialiser that groups Steps & Heart Rate by day and week
    init(steps: [Step], heartRates: [HeartRate]) {
        self.steps = steps
        self.heartRates = heartRates
        
        // Group daily steps data by week
        var stepsWeeks = [StepsWeek]()
        var weekSteps = [Step]()
     
        // NEED date??
        
            for step in steps {
                if weekSteps.count <  7 {
                    weekSteps.append(step)
                } else {
                    weekSteps.removeAll()
                    stepsWeeks.append(StepsWeek(steps: weekSteps))
                    weekSteps.append(step) //new

                }
            }

        
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
                    
//                    print(heartRate) // good, prints a lot of things
                }
            }

            // Close the last group as well
            let group = HeartRateDateGroup(date: date, heartRates: heartRates)
            groups.append(group)
            self.heartRateDateGroups = groups
            let weeks  = Dictionary(grouping: groups) { group in
                group.date.startOfWeek(using: calendar)
            }
            .sorted(by: { $0.key < $1.key })
            self.weeks = weeks.reversed()
            
            // Calculate the min, max, ...
            maxHeartRates = heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) })
            minHeartRates = heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) })
            min = CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0)
            max =  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0)
        }
        
        ySpan = max - min
        yFactor = ((hrGraphHeight - sampleSize) / ySpan)
    }


    // MARK: - Heart Rate Chart related
    private var weeks: [(key: Date, value: [HeartRateDateGroup])]

    let maxHeartRates: Int
    let minHeartRates: Int

    let hrGraphHeight: CGFloat = 260

    let sampleSize: CGFloat = 40

    let min: CGFloat
    let max: CGFloat

    let ySpan: CGFloat
    let yFactor: CGFloat

    var heartRateChartTitle: some View {
        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
            .font(.title2)
            .foregroundColor(Color(.systemPink))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .position(.init(x: 80, y: 30))
    }
    
    var heartRateChartDescription: some View {
        
    Text("Try to keep your heart rate below 70😊 You know you are doing great if you are seeing many Greens!")
        .foregroundColor(Color(.systemGray))
        .lineLimit(5)
        .multilineTextAlignment(.leading)
        .frame(width: 380, height: 100)

    }
    
    
    var heartRateChart: some View {

        TabView(selection: $selectedHeartRateDay) {

                ForEach(weeks, id: \.key) { (date, week) in
                    heartRateChartWeek(week)
                }

        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
    }

    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
        HStack(alignment: .bottom) {
            ForEach(week, id: \.id) { group in
                VStack {
                    Text(String(describing: group.maxHR))
                        .foregroundColor(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
                        .fontWeight(.bold)
                        // TODO: replace 120 with actual threshold set by user
                        .offset(y: 20)
                        
        
                    ZStack(alignment: .bottom) {

                        ForEach(group.ranges, id: \.id) { heartRate in
                            let yValue = (CGFloat(heartRate.averageHR) - min) * yFactor
                            let height = CGFloat(heartRate.deltaHR) * yFactor
                            RoundedRectangle(cornerRadius: sampleSize/2)
//                                .fill(Color(.systemPink))
                                .fill(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
//                                .overlay(Text(String(describing: heartRate.count))) // KEEP
                                .offset(x: 0, y: (height / 2) - yValue )
                                .frame(width: sampleSize, height: height)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }

                    }
                    .padding(.vertical, sampleSize/2)
                    .frame(height: hrGraphHeight)
                    
                    Text(String(describing: group.minHR)) // minHR here
                        .foregroundColor(Color(.systemGray))
                        .fontWeight(.bold)
                        // TODO: replace 120 with actual threshold set by user
                        .offset(y: -20)

                    Text("\(group.date, formatter: Self.dateFormatter)")
                        .offset(y: -20)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                    
                    // TODO: SHOW max and min hr of the day
                }
            }
        }
    }

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
    
    let steps: [Step]
    let weekSteps = [Step]()
    
    var body: some View {
        StepsChartTitle()
        StepsChart(steps: steps)
        StepsChartCeilingText()
    }
    
    
}


struct StepsChartTitle:  View {

    var body: some View {
        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
            .font(.title2)
            .foregroundColor(Color(.systemRed))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
        
        Text("Try to keep your daily steps below 2000😊 You know you are doing great if you are seeing many Green bars!")
            .foregroundColor(Color(.systemGray))
            .lineLimit(5)
            .multilineTextAlignment(.leading)
            .frame(width: 390, height: 100)
    }
}

struct StepsChart: View {
    
    let steps: [Step]
    
//    var weeks: [(key: Date, value: [HeartRateDateGroup])]

    var body: some View {
    
        TabView() {
//            // wrong here: sth to do with weekly grouping should be here
//            ForEach(weekSteps, id: \.key) {(date, week) in
            ForEach(steps, id: \.id) { step in
                stepsChartWeek(steps: steps)
            }
            
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(width: 390, height: 300)
        
    }
    

}
    

struct stepsChartWeek: View {
    
    let steps: [Step]
    let graphHeight: CGFloat = 260
    
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

            // TODO: instead of steps, should group here?
            ForEach(steps, id: \.id) { step in
                    let yValue = CGFloat(step.count) * yFactor
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
                                .frame(height: CGFloat(yValue))
                                .overlay(
                                    Text("\(step.count)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
                                        .offset(y: -20),
                                    alignment: .top
                                )
                                .frame(height: graphHeight, alignment: .bottom)

                            Text("\(step.date, formatter: Self.dateFormatter)")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                        }
                        .frame(width: 42)
                    
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

























//
//import SwiftUI
//
//
//struct SummaryTabView: View {
//
//    // Get the user's default calendar preference (week starts from Mon/Sun)
//    @Environment(\.calendar) private var calendar
//    @State var selectedHeartRateDay: Date = .distantPast
//    var weeks: [(key: Date, value: [HeartRateDateGroup])]
//
//    let steps: [Step]
//    let heartRates: [HeartRate]
//    let heartRateDateGroups: [HeartRateDateGroup]
//
//    // MARK: - Steps chart related
//    var totalSteps: Int { steps.map { $0.count }.reduce(0, +) }
//    var totalHeartRates: Int { heartRates.map { $0.count }.reduce(0, +) }
//
//
//    // MARK: - Heart Rate Chart related
////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
//
//    var maxHeartRates: Int { heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) }) }
//    var minHeartRates: Int { heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) }) }
//
//    let hrGraphHeight: CGFloat = 260
//
//    let sampleSize: CGFloat = 40
//
//    var min: CGFloat { CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0) }
//    var max: CGFloat {  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0) }
//
//    var ySpan: CGFloat { max - min }
//    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
//
//    static let dateFormatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd/MM"
//            return formatter
//        }()
//
//
//
//    var body: some View {
//
//        NavigationView {
//            ScrollView {
//
//                    VStack(alignment: .leading) {
//
//                        // STEP COUNT SECTION
//                        stepsChartTitle()
//                        ScrollView(.horizontal) { stepsChart(steps: steps, heartRates: heartRates, heartRateDateGroups: heartRateDateGroups) }
//                        stepsChartCeilingText()
//
//                        // HEART RATE SECTION
//                        heartRateChartTitle()
//                        heartRateChart(heartRates: heartRates, heartRateDateGroups: heartRateDateGroups, weeks: weeks)
////                        (weeks: weeks, heartRates: [HeartRateDateGroup])
//                        heartRateChartCeilingText()
//                    }
//                    .background(Color(.white))
//                    .cornerRadius(10)
//                    .padding(10)
//
//                }
//                .navigationTitle("Summary")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: {
//                            // TODO: Add JSON things here, when ready!
//                            print("Remember to Add JSONSymptoms functions here!")
//                        }, label: {
//                            Text("Add Symptom")
//                        })
//                    }
//                }
//
//        }
//        .onFirstAppear {
//            DispatchQueue.main.async {
//                selectedHeartRateDay = weeks.last?.key ?? .distantPast
//            }
//        }
//    }
//
//    // MARK: - Initialiser that groups the Heart Rate samples by day
//    init(steps: [Step], heartRates: [HeartRate]) {
//        self.steps = steps
//        self.heartRates = heartRates
//
//        if heartRates.isEmpty {
//            self.heartRateDateGroups = []
//            self.weeks = []
//        } else {
//            var groups = [HeartRateDateGroup]()
//            var date = heartRates[0].date
//            let calendar = Calendar.current
//
//            let parameterHeartRates = heartRates
//            var heartRates: [HeartRate] = []
//
//            for heartRate in parameterHeartRates {
//                if calendar.isDate(date, inSameDayAs: heartRate.date) {
//                    heartRates.append(heartRate)
//                } else {
//                    // Created new group based on the existing data
//                    let group = HeartRateDateGroup(date: date, heartRates: heartRates)
//                    groups.append(group)
//
//                    // Clean up
//                    heartRates.removeAll()
//                    date = heartRate.date
//
//                    // Add the new record
//                    heartRates.append(heartRate)
//                }
//            }
//
//            // Close the last group as well
//            let group = HeartRateDateGroup(date: date, heartRates: heartRates)
//            groups.append(group)
//            self.heartRateDateGroups = groups
//            let weeks  = Dictionary(grouping: groups) { group in
//                group.date.startOfWeek(using: calendar)
//            }
//            .sorted(by: { $0.key < $1.key })
//            self.weeks = weeks
//        }
//    }
//}
//
//
//extension Date {
//    func startOfWeek(using calendar: Calendar) -> Date {
//        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
//    }
//}
//
//
//
//// MARK: - STEPS
//
//struct stepsChartTitle: View {
//
//    var body: some View {
//        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
//            .font(.title2)
//            .foregroundColor(Color(.systemRed))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//    }
//
//}
//
//
//
//struct stepsChart: View {
//
//    let steps: [Step]
//    let heartRates: [HeartRate]
//    let heartRateDateGroups: [HeartRateDateGroup]
//
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM"
//        return formatter
//    }()
//
//    let hrGraphHeight: CGFloat = 260
//
////    static let dateFormatter: DateFormatter = {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "dd/MM"
////        return formatter
////    }()
//
//    var body: some View {
//
//        let dateFormatter: DateFormatter = {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "dd/MM"
//                return formatter
//            }()
//
//        let max = CGFloat(steps.map(\.count).max() ?? 0)
//        let min: CGFloat = 0
//        let ySpan: CGFloat = max - min
//        let yFactor: CGFloat = hrGraphHeight / ySpan
//
//        return HStack(alignment: .lastTextBaseline) {
//
//            ForEach(steps, id: \.id) { step in
//                let yValue = CGFloat(step.count) * yFactor
//
//                VStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
//                        .frame(height: CGFloat(yValue))
//                        .overlay(
//                            Text("\(step.count)")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                                .foregroundColor(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
//                                .offset(y: -20),
//                            alignment: .top
//                        )
//                        .frame(height: hrGraphHeight, alignment: .bottom)
//
//                    Text("\(step.date, formatter: dateFormatter)")
//                        .font(.caption)
//                        .foregroundColor(Color.black)
//                }
//                .frame(width: 42)
//            }
//        }
//        .padding(.vertical, 30)
//    }
//
//}
//
//
//struct stepsChartCeilingText: View {
////    var totalSteps: Int { steps.map { $0.count }.reduce(0, +) } // need this depending on what I want to put here
//
//    var body: some View {
//        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
//            .font(.subheadline)
//            .fontWeight(.bold)
//            .foregroundColor(Color.black)
//    }
//
//}
//
//
//// MARK: - HEART RATE
//
//struct heartRateChartTitle: View {
//
//    var body: some View {
//        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
//            .font(.title2)
//            .foregroundColor(Color(.systemPink))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//            .position(.init(x: 80, y: 30))
//    }
//
//}
//
//struct heartRateChart: View {
//
//    @State var selectedHeartRateDay: Date = .distantPast
//
////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
////
////    var hrGraphHeight: CGFloat = 260
////    let sampleSize: CGFloat = 40
////
////    var ySpan: CGFloat { max - min }
////    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
////
//    let heartRates: [HeartRate]
//    let heartRateDateGroups: [HeartRateDateGroup]
//
//    var weeks: [(key: Date, value: [HeartRateDateGroup])]
//
//    var maxHeartRates: Int { heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) }) }
//    var minHeartRates: Int { heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) }) }
//
//    let hrGraphHeight: CGFloat = 260
//
//    let sampleSize: CGFloat = 40
//
//    var min: CGFloat { CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0) }
//    var max: CGFloat {  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0) }
//
//    var ySpan: CGFloat { max - min }
//    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
//
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM"
//        return formatter
//    }()
//
//    var body: some View {
//
//        // TODO: Change this to lazyHStack, not TabView
//        TabView(selection: $selectedHeartRateDay) {
//            ForEach(weeks, id: \.key) { (date, week) in
//                heartRateChartWeek(weeks)
//            }
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
//    }
//
//    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
//            HStack(alignment: .bottom) {
//                ForEach(week, id: \.id) { group in
//                    VStack {
//                        ZStack(alignment: .bottom) {
//
//                            ForEach(group.heartRates, id: \.id) { heartRate in
//                                let yValue = (CGFloat(heartRate.count) - min) * yFactor
//                                RoundedRectangle(cornerRadius: sampleSize/2)
//                                    .fill(Color(.systemPink))
//    //                                .overlay(Text(String(describing: heartRate.count))) // KEEP
//                                    .offset(x: 0, y: (sampleSize / 2) - yValue )
//                                    .frame(width: sampleSize, height: sampleSize)
//                                    .frame(maxHeight: .infinity, alignment: .bottom)
//                            }
//
//                        }
//                        .padding(.vertical, sampleSize/2)
//                        .frame(height: hrGraphHeight)
//
//                        Text("\(group.date, formatter: Self.dateFormatter)")
//                            .font(.caption)
//                            .foregroundColor(Color.gray)
//                    }
//                }
//            }
//
//    }
//}
//
//
//struct heartRateChartCeilingText: View {
//
//    var body: some View {
//        Text("Your Heart Rate ceiling this week: 70")
//            .font(.subheadline)
//            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//            .padding(.top, 20.0)
//    }
//
//}
//
//
//
//
//
//struct TrackMeHome_Previews: PreviewProvider {
////    struct Container: View {
////        @State private var selectedTab: Int = 1000
////        var body: some View {
////            TabView(selection: $selectedTab) {
////                ForEach(Array(0..<2000), id: \.self) { number in
////                    Text(String(describing: number))
////                        .tabItem { Text(String(describing: number)) }
////                        .id(number)
////                }
////            }
////            .tabViewStyle(PageTabViewStyle())
////        }
////    }
//
//    static var previews: some View {
//
//    let now = Date()
//            let startOfPreviousWeek = now.addingTimeInterval(-60*60*24*7).startOfWeek(using: .autoupdatingCurrent)
//
//            let heartRates: [HeartRate] = (0..<2).flatMap { weekOffset in
//                (0..<7).flatMap { dayOffset -> [HeartRate] in
//                    let day = startOfPreviousWeek.addingTimeInterval( (Double(7*weekOffset) + Double(dayOffset))*60*60*24)
//                    return (0..<3).map { sampleIndex in
//                        HeartRate(count: sampleIndex * 50, date: day)
//                    }
//                }
//            }
//
//            let tomorrow = now.addingTimeInterval(60*60*24)
//            let dayAfter = tomorrow.addingTimeInterval(60*60*24)
//            let steps = [
//                        Step(count: 3452, date: Date()),
//                        Step(count: 1234, date: Date()),
//                        Step(count: 1553, date: Date()),
//                        Step(count: 123, date: Date()),
//                        Step(count: 1223, date: Date()),
//                        Step(count: 5223, date: Date()),
//                        Step(count: 12023, date: Date())
//
//                   ]
//
////        let heartRates = [
////                    HeartRate(count: 80, date: Date()),
////                    HeartRate(count: 92, date: Date()),
////                    HeartRate(count: 105, date: Date()),
////                    HeartRate(count: 112, date: Date()),
////                    HeartRate(count: 180, date: Date()),
////                    HeartRate(count: 200, date: tomorrow),
////                    HeartRate(count: 102, date: dayAfter)
////
////        ]
//
//        SummaryTabView(steps: steps, heartRates: heartRates)
//
//    }
//}



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


// STEPS RELATED

//    var stepsChartTitle: some View {
//        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
//            .font(.title2)
//            .foregroundColor(Color(.systemRed))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//    }

//    var stepsChart: some View {
//        let max = CGFloat(steps.map(\.count).max() ?? 0)
//        let min: CGFloat = 0
//        let ySpan: CGFloat = max - min
//        let yFactor: CGFloat = hrGraphHeight / ySpan
//
//            return HStack(alignment: .lastTextBaseline) {
//
//                ForEach(steps, id: \.id) { step in
//                        let yValue = CGFloat(step.count) * yFactor
//
//                        VStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
//                                .frame(height: CGFloat(yValue))
//                                .overlay(
//                                    Text("\(step.count)")
//                                            .font(.caption)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
//                                        .offset(y: -20),
//                                    alignment: .top
//                                )
//                                .frame(height: hrGraphHeight, alignment: .bottom)
//
//                            Text("\(step.date, formatter: Self.dateFormatter)")
//                                .font(.caption)
//                                .foregroundColor(Color.black)
//                        }
//                        .frame(width: 42)
//                    }
//        }
//        .padding(.vertical, 30)
//    }

//    var stepsChartCeilingText: some View {
//        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
//            .font(.subheadline)
//            .fontWeight(.bold)
//            .foregroundColor(Color.black)
//    }




// HEART RATE RELATED


//    var heartRateChartTitle: some View {
//        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
//            .font(.title2)
//            .foregroundColor(Color(.systemPink))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//            .position(.init(x: 80, y: 30))
//    }

//    var heartRateChart: some View {
//        TabView(selection: $selectedHeartRateDay) {
//            ForEach(weeks, id: \.key) { (date, week) in
//                heartRateChartWeek(week)
//            }
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
//    }

//    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
//        HStack(alignment: .bottom) {
//            ForEach(week, id: \.id) { group in
//                VStack {
//                    ZStack(alignment: .bottom) {
//
//                        ForEach(group.heartRates, id: \.id) { heartRate in
//                            let yValue = (CGFloat(heartRate.count) - min) * yFactor
//                            RoundedRectangle(cornerRadius: sampleSize/2)
//                                .fill(Color(.systemPink))
////                                .overlay(Text(String(describing: heartRate.count))) // KEEP
//                                .offset(x: 0, y: (sampleSize / 2) - yValue )
//                                .frame(width: sampleSize, height: sampleSize)
//                                .frame(maxHeight: .infinity, alignment: .bottom)
//                        }
//
//                    }
//                    .padding(.vertical, sampleSize/2)
//                    .frame(height: hrGraphHeight)
//
//                    Text("\(group.date, formatter: dateFormatter)")
//                        .font(.caption)
//                        .foregroundColor(Color.gray)
//                }
//            }
//        }
//    }





















































//
//import SwiftUI
//
//
//struct SummaryTabView: View {
//
//    // Get the user's default calendar preference (week starts from Mon/Sun)
//    @Environment(\.calendar) private var calendar
//    @State private var selectedHeartRateDay: Date = .distantPast
//
//    @State var showStepsChartView = false
//
//    let steps: [Step]
//    let heartRates: [HeartRate]
//    let heartRateDateGroups: [HeartRateDateGroup]
//
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM"
//        return formatter
//    }()
//
//    var body: some View {
//
//        NavigationView {
//            ScrollView {
//                    VStack {
//
//                        Button(action: { showStepsChartView = true} ) {
//                            VStack (alignment: .leading){
//
//                                HStack (alignment: .top) {
//                                    Image(systemName: "flame.fill")
//
//                                    Text("Your Steps")
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//
//                                }
//
//                                Divider()
//
//                                StepsChartCeilingText()
//
//                            }
//                            .frame(minWidth: .infinity, minHeight: .infinity)
//
//                        }
//                        .sheet(isPresented: $showStepsChartView) { StepsChartView(steps: steps) }
//                        .foregroundColor(Color(.systemPink))
//                        .background(Color(.systemGray6)) // background of the rectangle
//                        .cornerRadius(8)
//
//
////                        // STEP COUNT SECTION
////                        StepsChartTitle()
////                        StepsChart(steps: steps)
////                        StepsChartCeilingText()
//
//                        Spacer()
//
//                        // HEART RATE SECTION
//                        heartRateChartTitle
//                        Spacer()
//                        heartRateChartDescription
//                        heartRateChart
//                        heartRateChartCeilingText
//                    }
////                    .background(Color(.white))
//                    .cornerRadius(10)
//                    .padding(10)
//
//                }
//                .navigationTitle("Summary")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: {
//                            // TODO: Add JSON things here, when ready!
//                            print("Remember to Add JSONSymptoms functions here!")
//                        }, label: {
//                            Text("Add Symptom")
//                        })
//                    }
//                }
//
//        }
//        .onFirstAppear {
//            DispatchQueue.main.async {
//                selectedHeartRateDay = weeks.last?.key ?? .distantPast
//            }
//        }
//    }
//
//    // MARK: - Initialiser that groups Steps & Heart Rate by day and week
//    init(steps: [Step], heartRates: [HeartRate]) {
//        self.steps = steps
//        self.heartRates = heartRates
//
//        // Group daily steps data by week
//        var stepsWeeks = [StepsWeek]()
//        var weekSteps = [Step]()
//
//
//        for step in steps {
//            if weekSteps.count < 7 {
//                weekSteps.append(step)
//            } else {
//                stepsWeeks.append(StepsWeek(steps: weekSteps))
//                weekSteps.removeAll()
//                weekSteps.append(step) //new
//
//            }
//        }
//
//        // Group heart rate
//        if heartRates.isEmpty {
//            self.heartRateDateGroups = []
//            self.weeks = []
//            maxHeartRates = Int.min
//            minHeartRates = Int.max
//            min = 0
//            max = 0
//        } else {
//            var groups = [HeartRateDateGroup]()
//            var date = heartRates[0].date
//            let calendar = Calendar.current
//
//            let parameterHeartRates = heartRates
//            var heartRates: [HeartRate] = []
//
//            for heartRate in parameterHeartRates {
//                if calendar.isDate(date, inSameDayAs: heartRate.date) {
//                    heartRates.append(heartRate)
//                } else {
//                    // Created new group based on the existing data
//                    let group = HeartRateDateGroup(date: date, heartRates: heartRates)
//                    groups.append(group)
//
//                    // Clean up
//                    heartRates.removeAll()
//                    date = heartRate.date
//
//                    // Add the new record
//                    heartRates.append(heartRate)
//
////                    print(heartRate) // good, prints a lot of things
//                }
//            }
//
//            // Close the last group as well
//            let group = HeartRateDateGroup(date: date, heartRates: heartRates)
//            groups.append(group)
//            self.heartRateDateGroups = groups
//            let weeks  = Dictionary(grouping: groups) { group in
//                group.date.startOfWeek(using: calendar)
//            }
//            .sorted(by: { $0.key < $1.key })
//            self.weeks = weeks.reversed()
//
//            // Calculate the min, max, ...
//            maxHeartRates = heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) })
//            minHeartRates = heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) })
//            min = CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0)
//            max =  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0)
//        }
//
//        ySpan = max - min
//        yFactor = ((hrGraphHeight - sampleSize) / ySpan)
//    }
//
//
////     MARK: - Heart Rate Chart related
//    private var weeks: [(key: Date, value: [HeartRateDateGroup])]
//
//    let maxHeartRates: Int
//    let minHeartRates: Int
//
//    let hrGraphHeight: CGFloat = 260
//
//    let sampleSize: CGFloat = 40
//
//    let min: CGFloat
//    let max: CGFloat
//
//    let ySpan: CGFloat
//    let yFactor: CGFloat
//
//    var heartRateChartTitle: some View {
//        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
//            .font(.title2)
//            .foregroundColor(Color(.systemPink))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//            .position(.init(x: 80, y: 30))
//    }
//
//    var heartRateChartDescription: some View {
//
//    Text("Try to keep your heart rate below the target😊 You know you are doing great if you are seeing many Greens!")
//        .foregroundColor(Color(.systemGray))
//        .lineLimit(5)
//        .multilineTextAlignment(.leading)
//        .frame(width: 380, height: 100)
//
//    }
//
//
//    var heartRateChart: some View {
//        // lazyHGrid here
////        ScrollView(.horizontal) {
////        LazyHStack {
//        TabView(selection: $selectedHeartRateDay) {
////            ForEach(weeks, id: \.key) { (date, week) in
////            if weeks.isEmpty {
////                EmptyView()
////            } else {
//                ForEach(weeks, id: \.key) { (date, week) in
//                    heartRateChartWeek(week)
//                }
////            }
//        }
////        }
//        .tabViewStyle(PageTabViewStyle())
//        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
//    }
//
//    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
//        HStack(alignment: .bottom) {
//            ForEach(week, id: \.id) { group in
//                VStack {
//                    Text(String(describing: group.maxHR))
//                        .foregroundColor(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
//                        .fontWeight(.bold)
//                        // TODO: replace 120 with actual threshold set by user
//                        .offset(y: 20)
//
//
//                    ZStack(alignment: .bottom) {
//
//                        ForEach(group.ranges, id: \.id) { heartRate in
//                            let yValue = (CGFloat(heartRate.averageHR) - min) * yFactor
//                            let height = CGFloat(heartRate.deltaHR) * yFactor
//                            RoundedRectangle(cornerRadius: sampleSize/2)
//                                .fill(group.maxHR > 120 ? Color(.systemPink) :Color(.systemGreen))
////                                .overlay(Text(String(describing: heartRate.count))) // KEEP
//                                .offset(x: 0, y: (height / 2) - yValue )
//                                .frame(width: sampleSize, height: height)
//                                .frame(maxHeight: .infinity, alignment: .bottom)
//                        }
//
//                    }
//                    .padding(.vertical, sampleSize/2)
//                    .frame(height: hrGraphHeight)
//
//                    Text("\(group.date, formatter: Self.dateFormatter)")
//                        .offset(y: -20)
//                        .font(.caption)
//                        .foregroundColor(Color.gray)
//
//                    // TODO: SHOW max and min hr of the day
//                }
//            }
//        }
//    }
//
//    // done
//    var heartRateChartCeilingText: some View {
//        Text("Your Heart Rate ceiling this week: 70")
//            .font(.subheadline)
//            .fontWeight(.bold)
//            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//            .padding(.top, 20.0)
//    }
//
//}
//
//
//extension Date {
//    func startOfWeek(using calendar: Calendar) -> Date {
//        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
//    }
//}
//
//// MARK: - STEPS related
//
//struct StepsChartView: View {
//
//    let steps: [Step]
//
//    var body: some View {
//        StepsChartTitle()
//        StepsChart(steps: steps)
//        StepsChartCeilingText()
//    }
//
//
//}
//
//struct StepsChartTitle:  View {
//
//    var body: some View {
//        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
//            .font(.title2)
//            .foregroundColor(Color(.systemRed))
//            .fontWeight(.bold)
//            .multilineTextAlignment(.leading)
//
//        Text("Try to keep your daily steps below the target😊 You know you are doing great if you are seeing many Green bars!")
//            .foregroundColor(Color(.systemGray))
//            .lineLimit(5)
//            .multilineTextAlignment(.leading)
//            .frame(width: 390, height: 100)
//    }
//}
//
//struct StepsChart: View {
//
//    let steps: [Step]
//
////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
//
//    var body: some View {
//
//        TabView() {
////            // wrong here: sth to do with weekly grouping should be here
////            ForEach(weeks, id: \.key) {(date, week) in
//            ForEach(steps, id: \.id) { step in
//                stepsChartWeek(steps: steps)
//            }
//
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .frame(width: 390, height: 300)
//
//    }
//
//
//}
//
//
//struct stepsChartWeek: View {
//
//    let steps: [Step]
//    let graphHeight: CGFloat = 260
//
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM"
//        return formatter
//    }()
//
//    var body: some View {
//        let max = CGFloat(steps.map(\.count).max() ?? 0)
//        let min: CGFloat = 0
//        let ySpan: CGFloat = max - min
//        let yFactor: CGFloat = graphHeight / ySpan
//
//        // COMPLETED STEP GRAPH VIEW FOR A WEEK
//        HStack(alignment: .lastTextBaseline) {
//
//            // TODO: instead of steps, should group here?
//            ForEach(steps, id: \.id) { step in
//                    let yValue = CGFloat(step.count) * yFactor
//
//                        VStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
//                                .frame(height: CGFloat(yValue))
//                                .overlay(
//                                    Text("\(step.count)")
//                                        .font(.caption)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(step.count > 2000 ? Color(.systemPink) :Color(.systemGreen))
//                                        .offset(y: -20),
//                                    alignment: .top
//                                )
//                                .frame(height: graphHeight, alignment: .bottom)
//
//                            Text("\(step.date, formatter: Self.dateFormatter)")
//                                .font(.caption)
//                                .foregroundColor(Color.black)
//                        }
//                        .frame(width: 42)
//
//                }
//
//
//        }
//        .padding(.vertical, 30)
//
//
//    }
//}
//
//
//
//struct StepsChartCeilingText: View {
//
//    var body: some View {
//        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
//            .font(.subheadline)
//            .fontWeight(.bold)
//            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//    }
//
//}
//
//
//
//
//
//struct TrackMeHome_Previews: PreviewProvider {
////    struct Container: View {
////        @State private var selectedTab: Int = 1000
////        var body: some View {
////            TabView(selection: $selectedTab) {
////                ForEach(Array(0..<2000), id: \.self) { number in
////                    Text(String(describing: number))
////                        .tabItem { Text(String(describing: number)) }
////                        .id(number)
////                }
////            }
////            .tabViewStyle(PageTabViewStyle())
////        }
////    }
//
//    static var previews: some View {
//
//    let now = Date()
//            let startOfPreviousWeek = now.addingTimeInterval(-60*60*24*7).startOfWeek(using: .autoupdatingCurrent)
//
//            let heartRates: [HeartRate] = (0..<2).flatMap { weekOffset in
//                (0..<7).flatMap { dayOffset -> [HeartRate] in
//                    let day = startOfPreviousWeek.addingTimeInterval( (Double(7*weekOffset) + Double(dayOffset))*60*60*24)
//                    return (0..<3).map { sampleIndex in
//                        HeartRate(count: sampleIndex * 50, date: day)
//                    }
//                }
//            }
//
//            let tomorrow = now.addingTimeInterval(60*60*24)
//            let dayAfter = tomorrow.addingTimeInterval(60*60*24)
//            let steps = [
//                        Step(count: 3452, date: Date()),
//                        Step(count: 1234, date: Date()),
//                        Step(count: 1553, date: Date()),
//                        Step(count: 123, date: Date()),
//                        Step(count: 1223, date: Date()),
//                        Step(count: 5223, date: Date()),
//                        Step(count: 12023, date: Date())
//
//                   ]
//
////        let heartRates = [
////                    HeartRate(count: 80, date: Date()),
////                    HeartRate(count: 92, date: Date()),
////                    HeartRate(count: 105, date: Date()),
////                    HeartRate(count: 112, date: Date()),
////                    HeartRate(count: 180, date: Date()),
////                    HeartRate(count: 200, date: tomorrow),
////                    HeartRate(count: 102, date: dayAfter)
////
////        ]
//
//        SummaryTabView(steps: steps, heartRates: heartRates)
//
//    }
//}
//
//
//
//// COMMENT OUT UNTIL THE averateHeartRates formulate is corrected.
////                        Text("Your average heart rate this week:  \(averageHeartRates)")
////                            .font(.subheadline)
////                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////                            .padding(.top, 3.0)
////                    }
////                    .padding(.bottom, 20.0)
//
//// ANOTHER STUFF
////                        Text("Your heart rate range this week: \(minHeartRates) - \(maxHeartRates)")
////                            .font(.subheadline)
////                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////                            .padding(.top, 20.0)
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////
////import SwiftUI
////
////
////struct SummaryTabView: View {
////
////    // Get the user's default calendar preference (week starts from Mon/Sun)
////    @Environment(\.calendar) private var calendar
////    @State var selectedHeartRateDay: Date = .distantPast
////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
////
////    let steps: [Step]
////    let heartRates: [HeartRate]
////    let heartRateDateGroups: [HeartRateDateGroup]
////
////    // MARK: - Steps chart related
////    var totalSteps: Int { steps.map { $0.count }.reduce(0, +) }
////    var totalHeartRates: Int { heartRates.map { $0.count }.reduce(0, +) }
////
////
////    // MARK: - Heart Rate Chart related
//////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
////
////    var maxHeartRates: Int { heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) }) }
////    var minHeartRates: Int { heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) }) }
////
////    let hrGraphHeight: CGFloat = 260
////
////    let sampleSize: CGFloat = 40
////
////    var min: CGFloat { CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0) }
////    var max: CGFloat {  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0) }
////
////    var ySpan: CGFloat { max - min }
////    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
////
////    static let dateFormatter: DateFormatter = {
////            let formatter = DateFormatter()
////            formatter.dateFormat = "dd/MM"
////            return formatter
////        }()
////
////
////
////    var body: some View {
////
////        NavigationView {
////            ScrollView {
////
////                    VStack(alignment: .leading) {
////
////                        // STEP COUNT SECTION
////                        stepsChartTitle()
////                        ScrollView(.horizontal) { stepsChart(steps: steps, heartRates: heartRates, heartRateDateGroups: heartRateDateGroups) }
////                        stepsChartCeilingText()
////
////                        // HEART RATE SECTION
////                        heartRateChartTitle()
////                        heartRateChart(heartRates: heartRates, heartRateDateGroups: heartRateDateGroups, weeks: weeks)
//////                        (weeks: weeks, heartRates: [HeartRateDateGroup])
////                        heartRateChartCeilingText()
////                    }
////                    .background(Color(.white))
////                    .cornerRadius(10)
////                    .padding(10)
////
////                }
////                .navigationTitle("Summary")
////                .toolbar {
////                    ToolbarItem(placement: .navigationBarTrailing) {
////                        Button(action: {
////                            // TODO: Add JSON things here, when ready!
////                            print("Remember to Add JSONSymptoms functions here!")
////                        }, label: {
////                            Text("Add Symptom")
////                        })
////                    }
////                }
////
////        }
////        .onFirstAppear {
////            DispatchQueue.main.async {
////                selectedHeartRateDay = weeks.last?.key ?? .distantPast
////            }
////        }
////    }
////
////    // MARK: - Initialiser that groups the Heart Rate samples by day
////    init(steps: [Step], heartRates: [HeartRate]) {
////        self.steps = steps
////        self.heartRates = heartRates
////
////        if heartRates.isEmpty {
////            self.heartRateDateGroups = []
////            self.weeks = []
////        } else {
////            var groups = [HeartRateDateGroup]()
////            var date = heartRates[0].date
////            let calendar = Calendar.current
////
////            let parameterHeartRates = heartRates
////            var heartRates: [HeartRate] = []
////
////            for heartRate in parameterHeartRates {
////                if calendar.isDate(date, inSameDayAs: heartRate.date) {
////                    heartRates.append(heartRate)
////                } else {
////                    // Created new group based on the existing data
////                    let group = HeartRateDateGroup(date: date, heartRates: heartRates)
////                    groups.append(group)
////
////                    // Clean up
////                    heartRates.removeAll()
////                    date = heartRate.date
////
////                    // Add the new record
////                    heartRates.append(heartRate)
////                }
////            }
////
////            // Close the last group as well
////            let group = HeartRateDateGroup(date: date, heartRates: heartRates)
////            groups.append(group)
////            self.heartRateDateGroups = groups
////            let weeks  = Dictionary(grouping: groups) { group in
////                group.date.startOfWeek(using: calendar)
////            }
////            .sorted(by: { $0.key < $1.key })
////            self.weeks = weeks
////        }
////    }
////}
////
////
////extension Date {
////    func startOfWeek(using calendar: Calendar) -> Date {
////        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
////    }
////}
////
////
////
////// MARK: - STEPS
////
////struct stepsChartTitle: View {
////
////    var body: some View {
////        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
////            .font(.title2)
////            .foregroundColor(Color(.systemRed))
////            .fontWeight(.bold)
////            .multilineTextAlignment(.leading)
////    }
////
////}
////
////
////
////struct stepsChart: View {
////
////    let steps: [Step]
////    let heartRates: [HeartRate]
////    let heartRateDateGroups: [HeartRateDateGroup]
////
////    static let dateFormatter: DateFormatter = {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "dd/MM"
////        return formatter
////    }()
////
////    let hrGraphHeight: CGFloat = 260
////
//////    static let dateFormatter: DateFormatter = {
//////        let formatter = DateFormatter()
//////        formatter.dateFormat = "dd/MM"
//////        return formatter
//////    }()
////
////    var body: some View {
////
////        let dateFormatter: DateFormatter = {
////                let formatter = DateFormatter()
////                formatter.dateFormat = "dd/MM"
////                return formatter
////            }()
////
////        let max = CGFloat(steps.map(\.count).max() ?? 0)
////        let min: CGFloat = 0
////        let ySpan: CGFloat = max - min
////        let yFactor: CGFloat = hrGraphHeight / ySpan
////
////        return HStack(alignment: .lastTextBaseline) {
////
////            ForEach(steps, id: \.id) { step in
////                let yValue = CGFloat(step.count) * yFactor
////
////                VStack {
////                    RoundedRectangle(cornerRadius: 10)
////                        .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
////                        .frame(height: CGFloat(yValue))
////                        .overlay(
////                            Text("\(step.count)")
////                                .font(.caption)
////                                .fontWeight(.bold)
////                                .foregroundColor(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
////                                .offset(y: -20),
////                            alignment: .top
////                        )
////                        .frame(height: hrGraphHeight, alignment: .bottom)
////
////                    Text("\(step.date, formatter: dateFormatter)")
////                        .font(.caption)
////                        .foregroundColor(Color.black)
////                }
////                .frame(width: 42)
////            }
////        }
////        .padding(.vertical, 30)
////    }
////
////}
////
////
////struct stepsChartCeilingText: View {
//////    var totalSteps: Int { steps.map { $0.count }.reduce(0, +) } // need this depending on what I want to put here
////
////    var body: some View {
////        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
////            .font(.subheadline)
////            .fontWeight(.bold)
////            .foregroundColor(Color.black)
////    }
////
////}
////
////
////// MARK: - HEART RATE
////
////struct heartRateChartTitle: View {
////
////    var body: some View {
////        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
////            .font(.title2)
////            .foregroundColor(Color(.systemPink))
////            .fontWeight(.bold)
////            .multilineTextAlignment(.leading)
////            .position(.init(x: 80, y: 30))
////    }
////
////}
////
////struct heartRateChart: View {
////
////    @State var selectedHeartRateDay: Date = .distantPast
////
//////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
//////
//////    var hrGraphHeight: CGFloat = 260
//////    let sampleSize: CGFloat = 40
//////
//////    var ySpan: CGFloat { max - min }
//////    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
//////
////    let heartRates: [HeartRate]
////    let heartRateDateGroups: [HeartRateDateGroup]
////
////    var weeks: [(key: Date, value: [HeartRateDateGroup])]
////
////    var maxHeartRates: Int { heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) }) }
////    var minHeartRates: Int { heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) }) }
////
////    let hrGraphHeight: CGFloat = 260
////
////    let sampleSize: CGFloat = 40
////
////    var min: CGFloat { CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0) }
////    var max: CGFloat {  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0) }
////
////    var ySpan: CGFloat { max - min }
////    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
////
////    static let dateFormatter: DateFormatter = {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "dd/MM"
////        return formatter
////    }()
////
////    var body: some View {
////
////        // TODO: Change this to lazyHStack, not TabView
////        TabView(selection: $selectedHeartRateDay) {
////            ForEach(weeks, id: \.key) { (date, week) in
////                heartRateChartWeek(weeks)
////            }
////        }
////        .tabViewStyle(PageTabViewStyle())
////        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
////    }
////
////    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
////            HStack(alignment: .bottom) {
////                ForEach(week, id: \.id) { group in
////                    VStack {
////                        ZStack(alignment: .bottom) {
////
////                            ForEach(group.heartRates, id: \.id) { heartRate in
////                                let yValue = (CGFloat(heartRate.count) - min) * yFactor
////                                RoundedRectangle(cornerRadius: sampleSize/2)
////                                    .fill(Color(.systemPink))
////    //                                .overlay(Text(String(describing: heartRate.count))) // KEEP
////                                    .offset(x: 0, y: (sampleSize / 2) - yValue )
////                                    .frame(width: sampleSize, height: sampleSize)
////                                    .frame(maxHeight: .infinity, alignment: .bottom)
////                            }
////
////                        }
////                        .padding(.vertical, sampleSize/2)
////                        .frame(height: hrGraphHeight)
////
////                        Text("\(group.date, formatter: Self.dateFormatter)")
////                            .font(.caption)
////                            .foregroundColor(Color.gray)
////                    }
////                }
////            }
////
////    }
////}
////
////
////struct heartRateChartCeilingText: View {
////
////    var body: some View {
////        Text("Your Heart Rate ceiling this week: 70")
////            .font(.subheadline)
////            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////            .padding(.top, 20.0)
////    }
////
////}
////
////
////
////
////
////struct TrackMeHome_Previews: PreviewProvider {
//////    struct Container: View {
//////        @State private var selectedTab: Int = 1000
//////        var body: some View {
//////            TabView(selection: $selectedTab) {
//////                ForEach(Array(0..<2000), id: \.self) { number in
//////                    Text(String(describing: number))
//////                        .tabItem { Text(String(describing: number)) }
//////                        .id(number)
//////                }
//////            }
//////            .tabViewStyle(PageTabViewStyle())
//////        }
//////    }
////
////    static var previews: some View {
////
////    let now = Date()
////            let startOfPreviousWeek = now.addingTimeInterval(-60*60*24*7).startOfWeek(using: .autoupdatingCurrent)
////
////            let heartRates: [HeartRate] = (0..<2).flatMap { weekOffset in
////                (0..<7).flatMap { dayOffset -> [HeartRate] in
////                    let day = startOfPreviousWeek.addingTimeInterval( (Double(7*weekOffset) + Double(dayOffset))*60*60*24)
////                    return (0..<3).map { sampleIndex in
////                        HeartRate(count: sampleIndex * 50, date: day)
////                    }
////                }
////            }
////
////            let tomorrow = now.addingTimeInterval(60*60*24)
////            let dayAfter = tomorrow.addingTimeInterval(60*60*24)
////            let steps = [
////                        Step(count: 3452, date: Date()),
////                        Step(count: 1234, date: Date()),
////                        Step(count: 1553, date: Date()),
////                        Step(count: 123, date: Date()),
////                        Step(count: 1223, date: Date()),
////                        Step(count: 5223, date: Date()),
////                        Step(count: 12023, date: Date())
////
////                   ]
////
//////        let heartRates = [
//////                    HeartRate(count: 80, date: Date()),
//////                    HeartRate(count: 92, date: Date()),
//////                    HeartRate(count: 105, date: Date()),
//////                    HeartRate(count: 112, date: Date()),
//////                    HeartRate(count: 180, date: Date()),
//////                    HeartRate(count: 200, date: tomorrow),
//////                    HeartRate(count: 102, date: dayAfter)
//////
//////        ]
////
////        SummaryTabView(steps: steps, heartRates: heartRates)
////
////    }
////}
//
//
//
//// COMMENT OUT UNTIL THE averateHeartRates formulate is corrected.
////                        Text("Your average heart rate this week:  \(averageHeartRates)")
////                            .font(.subheadline)
////                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////                            .padding(.top, 3.0)
////                    }
////                    .padding(.bottom, 20.0)
//
//// ANOTHER STUFF
////                        Text("Your heart rate range this week: \(minHeartRates) - \(maxHeartRates)")
////                            .font(.subheadline)
////                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////                            .padding(.top, 20.0)
//
//
//// STEPS RELATED
//
////    var stepsChartTitle: some View {
////        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
////            .font(.title2)
////            .foregroundColor(Color(.systemRed))
////            .fontWeight(.bold)
////            .multilineTextAlignment(.leading)
////    }
//
////    var stepsChart: some View {
////        let max = CGFloat(steps.map(\.count).max() ?? 0)
////        let min: CGFloat = 0
////        let ySpan: CGFloat = max - min
////        let yFactor: CGFloat = hrGraphHeight / ySpan
////
////            return HStack(alignment: .lastTextBaseline) {
////
////                ForEach(steps, id: \.id) { step in
////                        let yValue = CGFloat(step.count) * yFactor
////
////                        VStack {
////                            RoundedRectangle(cornerRadius: 10)
////                                .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
////                                .frame(height: CGFloat(yValue))
////                                .overlay(
////                                    Text("\(step.count)")
////                                            .font(.caption)
////                                            .fontWeight(.bold)
////                                            .foregroundColor(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
////                                        .offset(y: -20),
////                                    alignment: .top
////                                )
////                                .frame(height: hrGraphHeight, alignment: .bottom)
////
////                            Text("\(step.date, formatter: Self.dateFormatter)")
////                                .font(.caption)
////                                .foregroundColor(Color.black)
////                        }
////                        .frame(width: 42)
////                    }
////        }
////        .padding(.vertical, 30)
////    }
//
////    var stepsChartCeilingText: some View {
////        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
////            .font(.subheadline)
////            .fontWeight(.bold)
////            .foregroundColor(Color.black)
////    }
//
//
//
//
//// HEART RATE RELATED
//
//
////    var heartRateChartTitle: some View {
////        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
////            .font(.title2)
////            .foregroundColor(Color(.systemPink))
////            .fontWeight(.bold)
////            .multilineTextAlignment(.leading)
////            .position(.init(x: 80, y: 30))
////    }
//
////    var heartRateChart: some View {
////        TabView(selection: $selectedHeartRateDay) {
////            ForEach(weeks, id: \.key) { (date, week) in
////                heartRateChartWeek(week)
////            }
////        }
////        .tabViewStyle(PageTabViewStyle())
////        .frame(height: 300) // I'm hardcoding both chart content's heigth and this height.
////    }
//
////    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
////        HStack(alignment: .bottom) {
////            ForEach(week, id: \.id) { group in
////                VStack {
////                    ZStack(alignment: .bottom) {
////
////                        ForEach(group.heartRates, id: \.id) { heartRate in
////                            let yValue = (CGFloat(heartRate.count) - min) * yFactor
////                            RoundedRectangle(cornerRadius: sampleSize/2)
////                                .fill(Color(.systemPink))
//////                                .overlay(Text(String(describing: heartRate.count))) // KEEP
////                                .offset(x: 0, y: (sampleSize / 2) - yValue )
////                                .frame(width: sampleSize, height: sampleSize)
////                                .frame(maxHeight: .infinity, alignment: .bottom)
////                        }
////
////                    }
////                    .padding(.vertical, sampleSize/2)
////                    .frame(height: hrGraphHeight)
////
////                    Text("\(group.date, formatter: dateFormatter)")
////                        .font(.caption)
////                        .foregroundColor(Color.gray)
////                }
////            }
////        }
////    }
//
