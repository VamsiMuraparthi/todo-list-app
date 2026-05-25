import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskItem
    var onToggleCompletion: () -> Void
    var onToggleAlarm: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Beautiful Animated Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onToggleCompletion()
                }
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color("CustomPurple") : Color.primary.opacity(0.25), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("CustomPurple"), Color("CustomIndigo")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                            .transition(.scale.combined(with: .opacity))
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content Details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.wrappedTitle)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                
                if !task.wrappedDetails.isEmpty {
                    Text(task.wrappedDetails)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Time & Alarm section
            VStack(alignment: .trailing, spacing: 6) {
                Text(formatTime(task.wrappedDueDate))
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(task.isCompleted ? .secondary : .primary.opacity(0.8))
                
                Button(action: {
                    withAnimation(.spring()) {
                        onToggleAlarm()
                    }
                }) {
                    Image(systemName: task.hasAlarm ? "bell.fill" : "bell.slash.fill")
                        .font(.system(size: 11))
                        .foregroundColor(
                            task.isCompleted ? .secondary.opacity(0.5) : 
                            (task.hasAlarm ? 
                                (task.wrappedDueDate < Date() ? Color.red : Color("CustomPurple")) : 
                                Color.primary.opacity(0.15))
                        )
                        .padding(5)
                        .background(
                            Circle()
                                .fill(task.hasAlarm && !task.isCompleted ? Color("CustomPurple").opacity(0.12) : Color.primary.opacity(0.03))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.primary.opacity(task.isCompleted ? 0.01 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.primary.opacity(task.isCompleted ? 0.03 : 0.06), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
