import SwiftUI

struct ContentView: View {
    @State private var selectedLine: TrainLine?
    @State private var showQuiz = false
    @State private var showRouteMap = false
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            TitleView(
                onStartQuiz: { line in
                    selectedLine = line
                    showQuiz = true
                },
                onShowRoute: { line in
                    selectedLine = line
                    showRouteMap = true
                },
                onSearch: { showSearch = true }
            )
            .navigationDestination(isPresented: $showQuiz) {
                if let line = selectedLine {
                    QuizView(line: line)
                }
            }
            .navigationDestination(isPresented: $showRouteMap) {
                if let line = selectedLine {
                    RouteMapView(line: line)
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView(
                    onSelectLine: { line in
                        showSearch = false
                        selectedLine = line
                        showRouteMap = true
                    }
                )
            }
        }
    }
}
