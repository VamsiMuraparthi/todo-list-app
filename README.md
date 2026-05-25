# 📱 Todo List iOS App

A modern and scalable Todo List application for iOS built using **SwiftUI**, **MVVM Architecture**, and clean modular structure.

The app helps users organize tasks efficiently with:
- 📅 Calendar-based task management
- 📊 Daily progress tracking
- ✅ Full CRUD operations
- 🎨 Modern SwiftUI interface
- ⚡ Smooth and reactive user experience

---

# 📸 Screenshots


# ✨ Features

## 📅 Calendar View
- Horizontal calendar at the top
- Select specific dates
- Highlight today’s date
- View tasks date-wise
- Smooth scrolling calendar experience

---

## ✅ Task Management (CRUD)

### Create Tasks
Users can:
- Add task title
- Add task description
- Select due date
- Set task priority

### Read Tasks
- View all tasks
- Filter by selected date
- View completed and pending tasks

### Update Tasks
- Edit task details
- Mark tasks as completed
- Update priorities and dates

### Delete Tasks
- Swipe to delete
- Delete confirmation support
- Optional undo functionality

---

## 📊 Progress Section
Displays:
- Daily completion percentage
- Completed tasks count
- Pending tasks count
- Productivity overview

---

## 🎨 Modern UI
- Built fully with SwiftUI
- Clean minimal design
- Responsive layouts
- Dark mode support
- Smooth animations

---

# 🏗️ Architecture

The application follows **MVVM (Model-View-ViewModel)** architecture with proper separation of concerns.

```text
Presentation Layer
│
├── Views
├── ViewModels
│
Business Layer
│
├── Helpers
├── Managers
│
Data Layer
│
├── Models
├── Persistence
```

---

# 📂 Folder Structure

```text
TodoApp/
│
├── Models/
│   ├── Task.swift
│   ├── TaskPriority.swift
│
├── ViewModels/
│   ├── TaskViewModel.swift
│   ├── CalendarViewModel.swift
│
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── TaskRowView.swift
│   │   ├── ProgressCardView.swift
│   │   └── CalendarView.swift
│   │
│   ├── AddTask/
│   │   └── AddTaskView.swift
│   │
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── EmptyStateView.swift
│       └── CustomTextField.swift
│
├── Helpers/
│   ├── DateHelper.swift
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Validators.swift
│
├── Managers/
│   ├── TaskStorageManager.swift
│   └── NotificationManager.swift
│
├── Resources/
│
└── TodoApp.swift
```

---

# 🛠️ Tech Stack

## Core Technologies
- Swift 5
- SwiftUI
- Combine
- MVVM Architecture

## Storage
- UserDefaults (basic)

OR

- CoreData / SwiftData (recommended)

## State Management
- `@State`
- `@StateObject`
- `@Published`
- `@ObservedObject`

---

# 📱 Main Screens

## 🏠 Home Screen

Contains:
- Calendar section
- Progress overview
- Task list
- Floating add button

---

## ➕ Add/Edit Task Screen

Features:
- Task title field
- Description field
- Date picker
- Priority selector
- Save button

---

## 📋 Task Card

Displays:
- Title
- Description
- Due date
- Completion status
- Edit/Delete actions

---

# 📊 Progress Calculation

The app calculates productivity progress using:

```text
Progress % = (Completed Tasks / Total Tasks) × 100
```

Example:

```text
Completed Tasks = 7
Total Tasks = 10

Progress = 70%
```

---

# 📦 Model Example

## Task.swift

```swift
import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var isCompleted: Bool
    var priority: TaskPriority
}
```

---

# 📦 ViewModel Example

## TaskViewModel.swift

```swift
import Foundation
import Combine

final class TaskViewModel: ObservableObject {

    @Published var tasks: [Task] = []

    func addTask(_ task: Task) {
        tasks.append(task)
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    func toggleTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: {
            $0.id == task.id
        }) else { return }

        tasks[index].isCompleted.toggle()
    }
}
```

---

# 📅 Calendar Features

The calendar supports:
- Weekly scrolling
- Monthly navigation
- Selected date state
- Date-based filtering

---

# 💾 Local Storage

Tasks can be persisted using:
- CoreData
- SwiftData
- UserDefaults (simple approach)

Recommended:
- ✅ SwiftData for iOS 17+
- ✅ CoreData for production apps

---

# 🔔 Optional Features

Future enhancements:
- Local notifications
- Task reminders
- Recurring tasks
- Cloud sync
- iCloud integration
- Widgets
- Siri shortcuts
- Apple Watch support

---

# ⚡ Performance Optimizations

- LazyVStack for task lists
- Efficient state updates
- Modular reusable views
- Combine-powered reactive updates

---

# 🧪 Testing

## Unit Testing
- ViewModels
- Helpers
- Managers

## UI Testing
- Task CRUD flows
- Calendar interactions

---

# 🚀 Installation

```bash
git clone https://github.com/yourusername/todo-ios-app.git
```

Open the project in Xcode and run on simulator/device.

---

# 📄 Requirements

- Xcode 15+
- iOS 16+
- Swift 5.9+

---

# 🤝 Contribution

Contributions are welcome.

Steps:
1. Fork repository
2. Create feature branch
3. Commit changes
4. Push branch
5. Create Pull Request

---

# 📄 License

MIT License

---

# 👨‍💻 Author

Built with SwiftUI and MVVM focusing on:
- Clean architecture
- Scalable structure
- High-performance UI
- Production-ready development practices
