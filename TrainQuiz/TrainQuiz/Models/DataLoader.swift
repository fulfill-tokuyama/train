import Foundation

final class DataLoader {
    static let shared = DataLoader()

    let trainData: TrainData

    private init() {
        guard let url = Bundle.main.url(forResource: "train_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(TrainData.self, from: data)
        else {
            fatalError("Failed to load train_data.json")
        }
        self.trainData = decoded
    }

    func lines(for group: LineGroup) -> [TrainLine] {
        trainData.lines.filter { $0.group == group.id }
    }

    func groups(for region: Region) -> [LineGroup] {
        trainData.groups.filter { $0.region == region.rawValue }
    }

    func findLines(forStation name: String) -> [TrainLine] {
        trainData.lines.filter { line in
            line.stations.contains { $0.name == name }
        }
    }

    func allStations() -> [StationInfo] {
        var map: [String: StationInfo] = [:]
        for line in trainData.lines {
            for station in line.stations {
                if map[station.name] == nil {
                    let rom = KanaRomaji.capitalizeStation(
                        KanaRomaji.toRomaji(station.reading)
                    )
                    map[station.name] = StationInfo(
                        name: station.name,
                        reading: station.reading,
                        romaji: rom,
                        lineNames: [],
                        lineColors: []
                    )
                }
                let lineName = line.name
                if !(map[station.name]!.lineNames.contains(lineName)) {
                    map[station.name]!.lineNames.append(lineName)
                    map[station.name]!.lineColors.append(line.color)
                }
            }
        }
        return Array(map.values).sorted { $0.reading < $1.reading }
    }
}

struct StationInfo: Identifiable {
    let name: String
    let reading: String
    let romaji: String
    var lineNames: [String]
    var lineColors: [String]

    var id: String { name }
}
