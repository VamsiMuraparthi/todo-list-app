import SwiftUI

struct CalendarHeaderView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var dates: [Date] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month & Navigation info
            HStack {
                Text(monthYearString(from: viewModel.selectedDate))
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        viewModel.selectedDate = Date()
                        HapticManager.shared.triggerImpact(style: .medium)
                    }
                }) {
                    Text("Today")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Capsule())
                        .foregroundColor(Color("CustomPurple"))
                }
            }
            .padding(.horizontal)
            
            // Scrollable weekly calendar view
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(dates, id: \.self) { date in
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                            let isToday = Calendar.current.isDateInToday(date)
                            let hasTasks = viewModel.hasTasks(on: date)
                            
                            VStack(spacing: 5) {
                                Text(dayAbbreviation(from: date))
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(isSelected ? .white : .secondary)
                                    .opacity(isSelected ? 1.0 : 0.7)
                                
                                Text(dayNumber(from: date))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(isSelected ? .white : (isToday ? Color("CustomPurple") : .primary))
                                    .frame(width: 34, height: 34)
                                    .background(
                                        ZStack {
                                            if isSelected {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color("CustomPurple"), Color("CustomIndigo")],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .shadow(color: Color("CustomPurple").opacity(0.4), radius: 5, x: 0, y: 2)
                                            } else if isToday {
                                                Circle()
                                                    .strokeBorder(Color("CustomPurple").opacity(0.6), lineWidth: 1.5)
                                            }
                                        }
                                    )
                                
                                // Dot indicator for tasks on this day
                                Circle()
                                    .fill(isSelected ? Color.white : Color("CustomPurple"))
                                    .frame(width: 4, height: 4)
                                    .opacity(hasTasks ? 1 : 0)
                            }
                            .frame(width: 46)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.primary.opacity(0.06) : Color.primary.opacity(0.02))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.primary.opacity(isSelected ? 0.12 : 0.04), lineWidth: 1)
                                    )
                            )
                            .id(date)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    viewModel.selectedDate = date
                                }
                                HapticManager.shared.triggerImpact(style: .light)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    setupDates()
                    // Auto-scroll to today on load
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let today = dates.first(where: { Calendar.current.isDateInToday($0) })
                        if let today = today {
                            proxy.scrollTo(today, anchor: .center)
                        }
                    }
                }
                .onChange(of: viewModel.selectedDate) { newDate in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        proxy.scrollTo(newDate, anchor: .center)
                    }
                }
            }
        }
    }
    
    private func setupDates() {
        let calendar = Calendar.current
        let today = Date()
        var list: [Date] = []
        // Generate a 4-week window (21 days before and 21 days after today) for wide sliding
        for i in -21...21 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                list.append(date)
            }
        }
        dates = list
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date).uppercased()
    }
    
    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
