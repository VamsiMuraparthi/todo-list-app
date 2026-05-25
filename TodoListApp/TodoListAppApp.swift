import SwiftUI

@main
struct TodoListAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTodoView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
