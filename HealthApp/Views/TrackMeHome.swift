//
//  TrackMeHome.swift
//  HealthApp
//
//  Created by Ko Sakuma on 22/06/2021.
//

import SwiftUI

// TODO: Move this to a seperate file
struct HeartRateDateGroup: Identifiable {
    var id = UUID()
    let date: Date
    let heartRates: [HeartRate]
}

struct TrackMeHome: View {

    // Get the user's default calendar preference (week starts from Mon/Sun)
    @Environment(\.calendar) private var calendar

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()

    let steps: [Step]
    let heartRates: [HeartRate]
    let heartRateDateGroups: [HeartRateDateGroup]
    
    var totalSteps: Int { steps.map { $0.count }.reduce(0, +) }
    var totalHeartRates: Int { heartRates.map { $0.count }.reduce(0, +) }
//    var averageHeartRates: Int { return totalHeartRates / 7 } // Wrong, 7 should be total count
    var maxHeartRates: Int { heartRates.map { $0.count }.reduce( Int.min, { Swift.max($0, $1) }) }
    var minHeartRates: Int { heartRates.map { $0.count }.reduce( Int.max, { Swift.min($0, $1) }) }

    // Grouping the Heart Rate sample by day
    init(steps: [Step], heartRates: [HeartRate]) {
        self.steps = steps
        self.heartRates = heartRates

        if heartRates.isEmpty {
            self.heartRateDateGroups = []
            self.weeks = []
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
                group.date.startOfWeek(using: calendar)
            }
            .sorted(by: { $0.key < $1.key })
            self.weeks = weeks
        }

    }
    
    
    // DEFINE VIEW
    var body: some View {
        
        NavigationView {
            ScrollView {

                    // STEP COUNT SECTION
                    VStack(alignment: .leading) {
                        stepsChartTitle
                        ScrollView(.horizontal) { stepsChart }
                        stepsChartCeilingText
                  
                    // HEART RATE SECTION
                        heartRateChartTitle
                        heartRateChart
                        heartRateChartCeilingText
                    }
                    .background(Color(.white))
                    .cornerRadius(10)
                    .padding(10)

                }
                .navigationTitle("Summary")

                //            .toolbar {
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    Button(action: {
                //
                //                    }, label: {
                //                        Text("Edit Thresholds")
                //                    })
                //                }
                //            }

        }
        .onFirstAppear {
            DispatchQueue.main.async {
                selectedHeartRateDay = weeks.last?.key ?? .distantPast
            }
        }
    }

    
    let hrGraphHeight: CGFloat = 260
    let sampleSize: CGFloat = 40
    var min: CGFloat { CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).min() ?? 0) }
    var max: CGFloat {  CGFloat(heartRateDateGroups.flatMap(\.heartRates).map(\.count).max() ?? 0) }
    var ySpan: CGFloat { max - min }
    var yFactor: CGFloat { ((hrGraphHeight - sampleSize) / ySpan) }
    
    
    var heartRateChartTitle: some View {
        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
            .font(.title2)
            .foregroundColor(Color(.systemPink))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .position(.init(x: 80, y: 30))
    }
    
    var heartRateChartCeilingText: some View {
        Text("Your Heart Rate ceiling this week: 70")
            .font(.subheadline)
            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
            .padding(.top, 20.0)
    }
    
    
    @State private var selectedHeartRateDay: Date = .distantPast
    
    var heartRateChart: some View {
        TabView(selection: $selectedHeartRateDay) {
            ForEach(weeks, id: \.key) { (_, week) in
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
                    ZStack(alignment: .bottom) {

                        ForEach(group.heartRates, id: \.id) { heartRate in
                            let yValue = (CGFloat(heartRate.count) - min) * yFactor
                            RoundedRectangle(cornerRadius: sampleSize/2)
                                .fill(Color.red)
                                .overlay(Text(String(describing: heartRate.count)))
                                .offset(x: 0, y: (sampleSize / 2) - yValue )
                                .frame(width: sampleSize, height: sampleSize)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .padding(.vertical, sampleSize/2)
                    .frame(height: hrGraphHeight)
                    Text("\(group.date, formatter: Self.dateFormatter)")
                        .font(.caption)
                        .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                }
            }
        }
    }

    var stepsChartTitle: some View {
        (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
            .font(.title2)
            .foregroundColor(Color(.systemRed))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
    }
    
    var stepsChartCeilingText: some View {
        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color.black)
    }
    
    var stepsChart: some View {
        let max = CGFloat(steps.map(\.count).max() ?? 0)
        let min: CGFloat = 0
        let ySpan: CGFloat = max - min
        let yFactor: CGFloat = hrGraphHeight / ySpan

            return HStack(alignment: .lastTextBaseline) {

                ForEach(steps, id: \.id) { step in
                        let yValue = CGFloat(step.count) * yFactor

                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
                                .frame(height: CGFloat(yValue))
                                .overlay(
                                    Text("\(step.count)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
                                        .offset(y: -20),
                                    alignment: .top
                                )
                                .frame(height: hrGraphHeight, alignment: .bottom)

                            Text("\(step.date, formatter: Self.dateFormatter)")
                                .font(.caption)
                                .foregroundColor(Color.black)
                        }
                        .frame(width: 42)
                    }
        }
        .padding(.vertical, 30)
    }
    
    private var weeks: [(key: Date, value: [HeartRateDateGroup])]
    
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

        TrackMeHome(steps: steps, heartRates: heartRates)

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

extension Date {
    func startOfWeek(using calendar: Calendar) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
