import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var hasAlarm: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sleek adaptive system background
                Color(uiColor: .systemBackground).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Title Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TASK TITLE")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        TextField("What do you want to accomplish?", text: $title)
                            .font(.system(.body, design: .rounded))
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                    
                    // Details/Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        TextField("Add extra notes here...", text: $details, axis: .vertical)
                            .font(.system(.body, design: .rounded))
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                    
                    // Date & Time Picker
                    DatePicker(selection: $dueDate, in: Date()...) {
                        Text("Schedule Time")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                    
                    // Alarm Switch Configuration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label {
                                Text("Set Alarm Notification")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                            } icon: {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(Color("CustomPurple"))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasAlarm)
                                .toggleStyle(SwitchToggleStyle(tint: Color("CustomPurple")))
                                .onChange(of: hasAlarm) { newValue in
                                    if newValue && !viewModel.hasNotificationPermission {
                                        viewModel.requestNotificationPermission()
                                    }
                                }
                        }
                        
                        if hasAlarm && !viewModel.hasNotificationPermission {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("Notification permissions are disabled. Please enable to receive alarms.")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(.yellow)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Settings")
                                        .font(.system(.caption, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color("CustomPurple"))
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Create Action Button
                    Button(action: {
                        viewModel.addTask(title: title, details: details, dueDate: dueDate, hasAlarm: hasAlarm)
                        dismiss()
                    }) {
                        Text("Create Task")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color("CustomPurple"), Color("CustomIndigo")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color("CustomPurple").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                }
                .padding(20)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.triggerImpact(style: .light)
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            viewModel.checkNotificationPermission()
            
            // Default picker to the calendar date selected
            let cal = Calendar.current
            let selectedDateComponents = cal.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
            let currentTimeComponents = cal.dateComponents([.hour, .minute], from: Date())
            
            var components = DateComponents()
            components.year = selectedDateComponents.year
            components.month = selectedDateComponents.month
            components.day = selectedDateComponents.day
            components.hour = currentTimeComponents.hour
            components.minute = currentTimeComponents.minute
            
            if let targetDate = cal.date(from: components), targetDate >= Date() {
                dueDate = targetDate
            } else {
                dueDate = Date().addingTimeInterval(300) // Default to 5 minutes from now if in the past
            }
        }
    }
}
