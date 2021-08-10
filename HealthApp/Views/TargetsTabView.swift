
import SwiftUI

// Note: Target = task in some places. Needs refactoring to targets.

struct TargetsTabView: View {
    
    @ObservedObject var taskManager = TaskManager.shared
    @State var showNotificationSettingsUI = false
    @State var showCreateTaskView = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                if taskManager.tasks.isEmpty {
                    Text("You haven't set any targets yet.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    List(taskManager.tasks) { task in
                        TargetsView(task: task)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Targets")
            .toolbar {
                // left 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        checkNotificationAuthStatus()
                    }, label: {
                        Image(systemName: "gear")
                            .font(.title)
                            .accentColor(.gray)
                        
                        //                        AddGoalView()
                        
                    })
                    .sheet(isPresented: $showNotificationSettingsUI) {
                        NotificationSettingsView()
                    }
                }
                
                // right
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button(
                        action: {
                            // TODO: If user didnt authorise, trigger auth menu. Else, execute.
                            showCreateTaskView = true
                        }, label: {
                            Text("Create")
                                .font(.body)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color.blue)
                                .padding()
                        })
                        .sheet(isPresented: $showCreateTaskView) {
                            CreateTaskView()
                        }
                    
                }
                
            }
        }
        
    }
    
    func checkNotificationAuthStatus() {
        
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                showNotificationSettingsUI = true
            }
        }
    }
    
}
    

// MARK: - SUPPORTING STRUCT: The added tasks in a list view. What i mainly see in the Goals tab.
struct TargetsView: View {
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


//// MARK: - SUPPORTING STRUCT: BUTTON TO CREATE A TASK
//struct AddGoalView: View {
//
//    @State var showCreateTaskView = false
//
//    var body: some View {
//        Button(
//            action: {
//                showCreateTaskView = true
//            }, label: {
//                Text("Add a Goal")
//                    .font(.body)
//                    .multilineTextAlignment(.trailing)
//                    .foregroundColor(Color.blue)
//                    .padding()
//            })
//            .sheet(isPresented: $showCreateTaskView) {
//                CreateTaskView()
//            }
//    }
//}


struct ContentView2_Previews: PreviewProvider {    // name changed here
  static var previews: some View {
    TargetsTabView()
  }
}




//            Color(#colorLiteral(red: 0.9490196108818054, green: 0.9490196108818054, blue: 0.9686274528503418, alpha: 1))
//                .ignoresSafeArea()
