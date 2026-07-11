import SwiftUI

struct SearchView: View {
    let onSelectLine: (TrainLine) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [StationInfo] = []
    @State private var selectedStation: StationInfo?
    @State private var matchingLines: [TrainLine] = []

    private let allStations = DataLoader.shared.allStations()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                if let station = selectedStation {
                    lineChoices(station: station)
                } else {
                    resultsList
                }
            }
            .background(Color(hex: "FFF8EC"))
            .navigationTitle("えきをさがす")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("えきめい・ひらがな・ローマじ", text: $query)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.systemGray4), lineWidth: 1)
        )
        .onChange(of: query) { _, newValue in
            selectedStation = nil
            search(newValue)
        }
    }

    // MARK: - Results

    private var resultsList: some View {
        Group {
            if query.isEmpty {
                ContentUnavailableView(
                    "えきめいをにゅうりょくしてね",
                    systemImage: "tram"
                )
            } else if results.isEmpty {
                ContentUnavailableView(
                    "みつかりません",
                    systemImage: "magnifyingglass"
                )
            } else {
                List(results) { station in
                    Button {
                        handleStationTap(station)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: station.lineColors.first ?? "999999"))
                                .frame(width: 10, height: 10)

                            Text(station.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)

                            Text(station.lineNames.joined(separator: ", "))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 1) {
                                Text(station.reading)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text(station.romaji)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(.systemGray))
                                    .italic()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Line Choices

    private func lineChoices(station: StationInfo) -> some View {
        VStack(spacing: 12) {
            Text("「\(station.name)」の ろせんを えらんでね")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Color(hex: "2C1810"))
                .padding(.top, 8)

            List(matchingLines) { line in
                Button {
                    onSelectLine(line)
                } label: {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: line.color))
                            .frame(width: 10, height: 10)
                        Text(line.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            Button {
                selectedStation = nil
            } label: {
                Text("もどる")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "3A7BE8"))
            }
            .padding(.bottom, 8)
        }
    }

    // MARK: - Search Logic

    private func search(_ query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        let q = KanaRomaji.toHiragana(query).lowercased()
        let qLo = query.lowercased()
        results = allStations.filter { s in
            s.name.contains(query)
            || KanaRomaji.toHiragana(s.reading).contains(q)
            || s.romaji.lowercased().contains(qLo)
        }
        .prefix(30)
        .map { $0 }
    }

    private func handleStationTap(_ station: StationInfo) {
        let lines = DataLoader.shared.findLines(forStation: station.name)
        if lines.count == 1 {
            onSelectLine(lines[0])
        } else {
            matchingLines = lines
            selectedStation = station
        }
    }
}
