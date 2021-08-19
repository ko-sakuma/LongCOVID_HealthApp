//
//  SwiftUIView.swift
//  HealthApp
//
//  Created by Ko Sakuma on 18/08/2021.
//

import SwiftUI

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
        
        HStack {
            VStack {
                Divider()
                Text("Count")
                   
                Divider()
                
                Text("\(Int(SettingsManager.stepCeiling))")
                    .offset(y: SettingsManager.stepCeiling * yFactor)
                    
                   
            }
            .font(.caption)
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
        .onChange(of: selectedID) { id in
            if let week = stepsWeeks.filter({ $0.id == id }).first {
                max = CGFloat(week.steps.map(\.count).max() ?? 0)
            }
        }
    }
}


struct StepsChartWeek: View {
    
    let steps: [Step]
    let graphHeight: CGFloat = 235 //was 260
    @State var selectedDay: Date?
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
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
        
        ZStack {
            Rectangle()
                .frame(height: 5)
                .offset(y: SettingsManager.stepCeiling * yFactor)
            
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
                            .frame(width: 50)
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
                                .onTapGesture {
                                    didSelect(step: step)
                                }
                        
                        Text("\(step.date, formatter: Self.dateFormatter)")
                            .font(.caption)
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(width: 40)
                }
        }
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
    
    var body: some View {
        Text("Your Step Count Ceiling this week: 2000 / day") // TODO: Replace hardcoded 2000 with actual goal set by user
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
