//
//  HeartRateChartView.swift
//  HealthApp
//
//  Created by Ko Sakuma on 18/08/2021.
//

import SwiftUI

struct HeartRateChartView: View {
    
    let heartRateDateGroups: [HeartRateDateGroup]
    @State var selectedHeartRateDay: Int
    @State var selectedDay: Int?
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    init(heartRates: [HeartRate]) {
        // Group heart rate
        if heartRates.isEmpty {
            self.heartRateDateGroups = []
            self.weeks = []
            maxHeartRates = Int.min
            minHeartRates = Int.max
            min = 0
            max = 0
            selectedHeartRateDay = 0
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
            selectedHeartRateDay = weeks.last?.key ?? 0
        }
        
        ySpan = max - min
        yFactor = ((hrGraphHeight - sampleSize) / ySpan)
        
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

    func minMaxTable(group: HeartRateDateGroup) -> some View {
        
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
            }
    }
    
        
    func heartRateChartWeek(_ week: [HeartRateDateGroup]) -> some View {
        
        HStack(alignment: .bottom) {
            
            ForEach(week, id: \.id) { group in
                VStack {
                    minMaxTable(group: group)
                    
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
                .contentShape(Rectangle()) //Note: this expands the gesture space
                .onTapGesture {
                    didSelect(group: group)
                }
            }
        }
        .sheet(item: $selectedDay) { timestamp in
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            SymptomsDailyView(date: date)
                .environmentObject(symptomJSONManager)
        }
    }
    
    func didSelect(group: HeartRateDateGroup) {
        selectedDay = Int(group.date.timeIntervalSince1970)
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

//struct HeartRateChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        HeartRateChartView()
//    }
//}
