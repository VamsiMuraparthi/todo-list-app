import SwiftUI
import CoreData

struct MainTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TodoViewModel
    @State private var showingAddTask = false
    
    // Custom initializer to set up the StateObject using the environment context
    init() {
        _viewModel = StateObject(wrappedValue: TodoViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        ZStack {
            // Sleek adaptive system background
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            // Subtle top background gradient glow
            VStack {
                LinearGradient(
                    colors: [Color("CustomPurple").opacity(0.12), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 250)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 18) {
                // Header Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TaskFlow")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                        
                        Text("Stay organized and on track")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Notification permission alert indicator
                    if !viewModel.hasNotificationPermission {
                        Button(action: {
                            viewModel.requestNotificationPermission()
                        }) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 16))
                                .padding(10)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Calendar header
                CalendarHeaderView(viewModel: viewModel)
                
                // Dynamic Progress Card
                progressCard
                
                // List Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("TASKS")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(viewModel.filteredTasks.count) scheduled")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.filteredTasks.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskRowView(
                                    task: task,
                                    onToggleCompletion: {
                                        viewModel.toggleTaskCompletion(task: task)
                                    },
                                    onToggleAlarm: {
                                        viewModel.toggleTaskAlarm(task: task)
                                    }
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            }
                            .onDelete(perform: viewModel.deleteTasks)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
            }
            
            // Premium Floating Action Button (FAB)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.triggerImpact(style: .medium)
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color("CustomPurple"), Color("CustomIndigo")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color("CustomPurple").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchTasks()
            viewModel.checkNotificationPermission()
        }
    }
    
    // MARK: - Subviews
    
    /// Elegant Dashboard Progress Card
    private var progressCard: some View {
        let total = viewModel.filteredTasks.count
        let completed = viewModel.filteredTasks.filter { $0.isCompleted }.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0.0
        
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(isTodaySelected ? "Today's Focus" : "Day Progress")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if total == 0 {
                    Text("No tasks scheduled. Enjoy your day!")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                } else if completed == total {
                    Text("All tasks completed! Excellent job. 🎉")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(total - completed) tasks remaining to complete.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if total > 0 {
                    // Modern Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.08))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("CustomPurple"), Color("CustomIndigo")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(percentage), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // Sleek Circular Ring progress indicator
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.05), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(percentage))
                    .stroke(
                        LinearGradient(
                            colors: [Color("CustomPurple"), Color("CustomIndigo")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: percentage)
                
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    /// Minimalist Empty State view
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 42))
                .foregroundColor(Color("CustomPurple").opacity(0.6))
                .padding(.bottom, 6)
            
            Text("Clear Agenda")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.primary)
            
            Text("No tasks scheduled for this day.\nTap '+' to create a new one.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 40)
    }
    
    // MARK: - Helpers
    
    private var isTodaySelected: Bool {
        Calendar.current.isDateInToday(viewModel.selectedDate)
    }
}

// Previews
struct MainTodoView_Previews: PreviewProvider {
    static var previews: some View {
        MainTodoView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
