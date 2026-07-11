import SwiftUI

struct RouteMapView: View {
    let line: TrainLine
    @Environment(\.dismiss) private var dismiss

    private var displayStations: [Station] {
        line.isLoop ? Array(line.stations.dropLast()) : line.stations
    }

    var body: some View {
        ZStack {
            Color(hex: "FFF8EC").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    stationList
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.bold)
                }
            }

            ToolbarItem(placement: .principal) {
                Text(line.name)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(Color(hex: line.color))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 8) {
            Text(line.company)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)

            Text(line.name)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(hex: "2C1810"))

            HStack(spacing: 8) {
                Text("\(displayStations.count)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(hex: line.color))
                Text("えき")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)

                if line.isLoop {
                    Label("かんじょう", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: line.color))
                }
            }

            if !line.isLoop {
                HStack {
                    StationSignView(station: displayStations.first!, fontSize: 14)
                    Text("↔")
                        .foregroundColor(.secondary)
                    StationSignView(station: displayStations.last!, fontSize: 14)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }

    // MARK: - Station List

    private var stationList: some View {
        VStack(spacing: 0) {
            ForEach(Array(displayStations.enumerated()), id: \.offset) { i, station in
                stationRow(station: station, index: i)
            }
        }
    }

    private func stationRow(station: Station, index: Int) -> some View {
        let count = displayStations.count
        let isFirst = index == 0
        let isLast = index == count - 1
        let isTerminal = isFirst || isLast

        return HStack(alignment: .center, spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 28, alignment: .trailing)

            ZStack {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(isFirst ? .clear : Color(hex: line.color))
                        .frame(width: 4)
                    Rectangle()
                        .fill(isLast ? .clear : Color(hex: line.color))
                        .frame(width: 4)
                }

                Circle()
                    .fill(isTerminal ? Color(hex: line.color) : .white)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(hex: line.color), lineWidth: 3)
                    )
            }
            .frame(width: 20, height: 52)

            HStack(spacing: 8) {
                StationSignView(station: station, fontSize: isTerminal ? 18 : 16)

                if isFirst {
                    terminalTag("しはつ")
                } else if isLast && !line.isLoop {
                    terminalTag("しゅうちゃく")
                } else if isLast && line.isLoop {
                    Text("→ \(displayStations.first!.name) へ")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: line.color))
                }

                Spacer()
            }
        }
    }

    private func terminalTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: line.color))
            .clipShape(Capsule())
    }
}
