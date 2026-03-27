import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
            WaterView()
                .tabItem {
                    Label("물", systemImage: "drop.fill")
                }
            MealView()
                .tabItem {
                    Label("식사", systemImage: "fork.knife")
                }
        }
    }
}
