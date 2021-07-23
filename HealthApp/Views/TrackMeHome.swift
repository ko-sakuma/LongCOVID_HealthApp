//
//  TrackMeHome.swift
//  HealthApp
//
//  Created by Ko Sakuma on 22/06/2021.
//

// TODO: Consider implementing Geometry Reader for the frames.

import SwiftUI

struct TrackMeHome: View {

    static let dateFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter

    }()

    let steps: [Step]
    let heartRates: [HeartRate]

    var totalSteps: Int {
        steps.map { $0.count }.reduce(0, +)
    }

    var totalHeartRates: Int {
        heartRates.map { $0.count }.reduce(0, +)
    }

    var averageHeartRates: Int {
        return totalHeartRates / 7 // Wrong here! has to be div by no.of heart rate counts
    }

    var maxHeartRates: Int {
        heartRates.map { $0.count }.reduce( Int.min, { max($0, $1) })
    }

    var minHeartRates: Int {
        heartRates.map { $0.count }.reduce( Int.max, { min($0, $1) })
    }

    // DEFINE VIEW
    var body: some View {

        NavigationView {

//            ZStack {
//
//                Color(#colorLiteral(red: 0.9490196108818054, green: 0.9490196108818054, blue: 0.9686274528503418, alpha: 1))
//                    .ignoresSafeArea()

            ScrollView {

            VStack {

                // STEP COUNT GRAPH
                VStack {

                    VStack {

                            (Text(Image(systemName: "flame.fill")) + Text(" Steps"))
                                .font(.title2)
                                .foregroundColor(Color(.systemRed))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .position(.init(x: 50, y: 30))

                        VStack {
                            HStack(alignment: .lastTextBaseline) {
                                    ForEach(steps, id: \.id) { step in

                                        let yValue = Swift.min(step.count/20, 300)

                                        VStack {
                                            Text("\(step.count)")
                                                .font(.caption)
                                                .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                                            Rectangle()
                                                .fill(step.count > 2000 ? Color(.systemOrange) :Color(.systemGreen))
                                                .frame(width: 20, height: CGFloat(yValue))
                                            Text("\(step.date, formatter: Self.dateFormatter)")
                                                .font(.caption)
                                                .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                                        }
                                    }

                            }
                            .frame(width: 400, height: 200)

//                            Text("Your steps this week: \(totalSteps)")
//                                .font(.subheadline)
//                                .padding(.top, 15.0)
//                                .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))

                            Text("Your Step Count Ceiling this week: 2000 / day")
                                .font(.subheadline)
                                .padding(.top, 70.0)
                                .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))

                        }

                    }

                }
                .frame(width: 380, height: 410, alignment: .bottom)
                .background(Color(.white))
                .cornerRadius(10)
                .padding(10)

//                Divider()

                // HEART RATE GRAPH
                VStack {
                    VStack {
                        (Text(Image(systemName: "heart.fill")) + Text(" Heart Rates"))
                            .font(.title2)
                            .foregroundColor(Color(.systemPink))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .position(.init(x: 80, y: 30))

                        HStack(alignment: .lastTextBaseline) {
                            ForEach(heartRates, id: \.id) { heartRate in       // need a Group by dates script?

                                let yValue = Swift.min(heartRate.count/20, 300)

                                VStack {
                                    Text("\(heartRate.count)")
                                        .font(.caption)
                                        .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                                    Rectangle()
                                        .fill(heartRate.count > 120 ? Color(#colorLiteral(red: 0.9843137264251709, green: 0.6627451181411743, blue: 0.13333334028720856, alpha: 1)) :Color.green)   // Above taget colour coding is here
                                        .frame(width: 20, height: CGFloat(yValue))
                                    Text("\(heartRate.date, formatter: Self.dateFormatter)")
                                        .font(.caption)
                                        .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                                }
                            }
                            .frame(height: 50)

                        }
                    }

                    VStack {
                        Text("Your heart rate range this week: \(minHeartRates) - \(maxHeartRates)")
                            .font(.subheadline)
                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                            .padding(.top, 20.0)

                        Text("Your Heart Rate ceiling this week: 70")
                            .font(.subheadline)
                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
                            .padding(.top, 20.0)

                        // COMMENT OUT UNTIL THE averateHeartRates formulate is corrected.
//                        Text("Your average heart rate this week:  \(averageHeartRates)")
//                            .font(.subheadline)
//                            .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//                            .padding(.top, 3.0)
                    }
                    .padding(.bottom, 20.0)

                }
                // END OF THE VSTACK FOR HEART RATE
                .frame(width: 380, height: 410, alignment: .bottom)
                .background(Color(.white))
                .cornerRadius(10)
                .padding(10)

            }
            .navigationTitle("Track")

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
        }
//        }
    }
}

struct TrackMeHome_Previews: PreviewProvider {
    static var previews: some View {

        let steps = [
                    Step(count: 3452, date: Date()),
                    Step(count: 1234, date: Date()),
                    Step(count: 1553, date: Date()),
                    Step(count: 123, date: Date()),
                    Step(count: 1223, date: Date()),
                    Step(count: 5223, date: Date()),
                    Step(count: 12023, date: Date())

               ]

        let heartRates = [
                    HeartRate(count: 100, date: Date()),
                    HeartRate(count: 102, date: Date()),
                    HeartRate(count: 105, date: Date()),
                    HeartRate(count: 102, date: Date()),
                    HeartRate(count: 102, date: Date()),
                    HeartRate(count: 152, date: Date()),
                    HeartRate(count: 102, date: Date())

        ]

        TrackMeHome(steps: steps, heartRates: heartRates)
    }
}
