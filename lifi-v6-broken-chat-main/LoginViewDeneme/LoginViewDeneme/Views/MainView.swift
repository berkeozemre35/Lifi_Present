import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()

    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            TabView {
                MainPageView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                EventView()
                    .tabItem {
                        Label("Event", systemImage: "calendar")
                    }

                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }

                ChatListView()
                    .tabItem {
                        Label("Chat", systemImage: "message")
                    }

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }

            }
        } else {
            LoginView()
        }
    }
}
 




