
// NOTE: The Views relating to Steps Chart are all here.

import SwiftUI
import Foundation

struct StepsChartView: View {
    
    // MARK: - Type definitions
    let stepsWeeks: [StepsWeek]
    
    // MARK: - Body
    var body: some View {
        
        ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            
            VStack {
                StepsChartTitle()
                StepsChartDescription()
                StepsChart(stepsWeeks: stepsWeeks)
                
                //        StepsChartCeilingText()
            }
    
        }
    }
}


struct StepsChartTitle:  View {
    
    // MARK: - Body
    var body: some View {
        
        (Text(Image(systemName: "figure.walk")) + Text(" Steps"))
            .font(.title2)
            .foregroundColor(Color(.systemRed))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .offset(x: -145)
            .padding(.top, 10)
        
        
//        (Text("Try to keep your daily steps below ") + Text("\(Int(SettingsManager.stepCeiling))").bold().foregroundColor(Color(.systemOrange)) + Text(" \nGreen bar ").bold().foregroundColor(Color(.systemGreen)) + Text("means you are meeting your daily goal! ") )
//            .foregroundColor(Color(.systemGray))
//            .lineLimit(4)
//            .multilineTextAlignment(.leading)
//            .frame(width: 390, height: 100)
//            .padding(.leading, 10)
//            .padding(.trailing, 10)

    }
}

struct StepsChartDescription: View {
    
    var body: some View {
        (Text("Try to keep your daily steps below ") + Text("\(Int(SettingsManager.stepCeiling))").bold().foregroundColor(Color(.systemOrange)) + Text(" \nGreen bar ").bold().foregroundColor(Color(.systemGreen)) + Text("means you are meeting your daily goal! ") )
            .foregroundColor(Color(.systemGray))
            .lineLimit(4)
            .multilineTextAlignment(.leading)
            .frame(width: 390, height: 100)
            .padding(.leading, 10)
            .padding(.trailing, 10)

    }
}


struct StepsChart: View {
    
    // MARK: - State
    @State var selectedID: Int
    @State var max: CGFloat = 0
    
    // MARK: - Passwed properties
    let stepsWeeks: [StepsWeek]
    
    init(stepsWeeks: [StepsWeek]) {
        self.stepsWeeks = stepsWeeks
        self.selectedID = stepsWeeks.last!.id
    }
    
    // MARK: - Body
    var body: some View {
        
        let graphHeight: CGFloat = 235
        let min: CGFloat = 0
        let ySpan: CGFloat = max - min
        let yFactor: CGFloat = graphHeight / ySpan
        
//        HStack {
//            VStack {
//                // y-axis labels
//
//
////                Divider()
//
//
////                Text("Count")
////
//////                Divider()
////
//                Text("\(Int(SettingsManager.stepCeiling))")
//                    .offset(y: SettingsManager.stepCeiling * yFactor)
//
//            }
//            .font(.caption)
//            .offset(y: -133)
//            .frame(height: graphHeight, alignment: .bottom)
////            .frame(width: 40)
        
        ZStack{
                
            // y-label
            Text("Count")
                .font(.caption)
                .fontWeight(.bold)
                .frame(height: graphHeight, alignment: .top)
                .offset( x: -179, y: -23)

            TabView(selection: $selectedID) {
                ForEach(stepsWeeks, id: \.id) { (week) in
                    StepsChartWeek(steps: week.steps).tag(week.id)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
        }
//
        .onChange(of: selectedID) { id in
            if let week = stepsWeeks.filter({ $0.id == id }).first {
                max = CGFloat(week.steps.map(\.count).max() ?? 0)
            }
        }
    }
}


struct StepsChartWeek: View {
    
    // MARK: - Environment
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    // MARK: - State
    @State var selectedDay: Date?
    
    // MARK: - Type definitions
    let steps: [Step]
    let graphHeight: CGFloat = 235
    
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    // MARK: - Body
    var body: some View {
        
        let max = CGFloat(steps.map(\.count).max() ?? 0)
        let min: CGFloat = 0
        let ySpan: CGFloat = max - min
        let yFactor: CGFloat = graphHeight / ySpan
        
        ZStack {
            
            // Ceiling line & y-axis label
            HStack {
                Text("\(Int(SettingsManager.stepCeiling))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.systemOrange))
//                    .offset(x: -1)
                
                RoundedRectangle(cornerRadius: 5)
                    .offset(x: -8)
                    .fill(Color(.systemYellow))
                    .frame(height: 5)
//                    .offset(y: SettingsManager.stepCeiling * yFactor)
            }
//            .frame(height: (inputted yValue of the week's chart * yFactor))
            .offset(y: (SettingsManager.stepCeiling * yFactor) * 0.5)
            // SettingsManager.stepCeiling * yFactor = yValue
            
            // Steps Graph View (7 days)
            HStack(alignment: .lastTextBaseline) {
                
                ForEach(steps, id: \.id) { step in
                    let yValue = CGFloat(step.count) * yFactor

                    VStack {
                        
                        // count number
                        Text("\(step.count)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(step.count > (Int(SettingsManager.stepCeiling)) ? Color(.systemPink) :Color(.systemGreen))
                            .frame(width: 50)
                        
                        // steps bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(step.count > (Int(SettingsManager.stepCeiling)) ? Color(.systemPink) :Color(.systemGreen))
                            //                                .frame(height: CGFloat(yValue))
                            .frame(height: CGFloat(yValue))
                            .frame(height: graphHeight, alignment: .bottom)
                            .onTapGesture {
                                didSelect(step: step)
                            }
                        
                        // x-axis label
                        Text("\(step.date, formatter: Self.dateFormatter)")
                            .font(.caption)
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(width: 40) //here
                }
            }
            .offset(x: 10)
            .padding(.vertical, 30)
            .sheet(item: $selectedDay) { date in
                SymptomsDailyView(date: date)
                    .environmentObject(symptomJSONManager)
                
               
            }
        }
        
    }
    
    func didSelect(step: Step) {
        
        selectedDay = step.date
    }
}


struct StepsChartCeilingText: View {
    
    // MARK: - Body
    var body: some View {
        (Text("Your Step Count Ceiling this week:") + Text("\(Int(SettingsManager.stepCeiling)) / day"))
                // TODO: Replace hardcoded 2000 with actual goal set by user
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemGray))
    }
    
}


//struct StepsChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsChartView()
//    }
//}
