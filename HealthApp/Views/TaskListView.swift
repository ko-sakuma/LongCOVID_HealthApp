//
//  ContentView.swift
//  NotificationsTest
//
//  Created by Ko Sakuma on 04/07/2021.
//

import SwiftUI

// VIEW
struct TaskListView: View {
  @ObservedObject var taskManager = TaskManager.shared
  @State var showNotificationSettingsUI = false

  var body: some View {

    NavigationView {
//        ScrollView {

        ZStack {

            Color(#colorLiteral(red: 0.9490196108818054, green: 0.9490196108818054, blue: 0.9686274528503418, alpha: 1))
                .ignoresSafeArea()

    VStack {

            ZStack {

                VStack {
                    HStack {
                    // KEEP THIS CODE UNTIL THIS IS TRANSFERRED TO SETTINGS
                    // SHOWS THE VIEW OF WHICH NOTIFS ARE ALLOWED
                    Spacer()

                    Button(
                        action: {
                          // 1
                          NotificationManager.shared.requestAuthorization { granted in
                            // 2
                            if granted {
                              showNotificationSettingsUI = true
                            }
                         }
                        },
                        label: {
                            Image(systemName: "gear")
//                                .hidden()
                                .font(.title)
                                .accentColor(.gray)
                            AddTaskView()
                    })
                        .padding(.trailing)
                        .sheet(isPresented: $showNotificationSettingsUI) {
                          NotificationSettingsView()
                        }

                }
//                .padding()

                if taskManager.tasks.isEmpty {
//
                    Spacer()
                    Text("You haven't set any reminders yet.")
                        .foregroundColor(.gray)
                        .font(.body)
                    Spacer()

                } else {
                  List(taskManager.tasks) { task in
                    TaskCell(task: task)
                  }
                  .padding()
                }
            }

        }
    }
    .navigationBarTitle("Remind")
        } // Z
  }

//    .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            AddTaskView()
//        }
//    }

//    }
  }
}

struct TaskCell: View {
  var task: Task

  var body: some View {
    HStack {
      Button(
        action: {
          TaskManager.shared.markTaskComplete(task: task)
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            TaskManager.shared.remove(task: task)
          }
        }, label: {
          Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
            .resizable()
            .frame(width: 20, height: 20)
            .accentColor(.green)
        })
      if task.completed {
        Text(task.name)
          .strikethrough()
          .foregroundColor(.green)
      } else {
        Text(task.name)
          .foregroundColor(.green)
      }
    }
  }
}

// SUPPORTING STRUCT
struct AddTaskView: View {
    // BUTTON TO CREATE A TASK
  @State var showCreateTaskView = false

  var body: some View {
//    VStack {
//      Spacer()
//      HStack {
//        Spacer()
        Button(
          action: {
            showCreateTaskView = true
          }, label: {
            Text("Add")
//            Image(systemName: "plus")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.blue)
                .padding()
          })
//          .background(Color.green)
//          .cornerRadius(40)
//          .padding()
          .sheet(isPresented: $showCreateTaskView) {
            CreateTaskView()
          }
      }
//      .padding(.bottom)  // TODO: may need to remove
    }
//  }
// }

// SUPPORTING STRUCT
struct ContentView2_Previews: PreviewProvider {    // name changed here
  static var previews: some View {
    TaskListView()
  }
}
