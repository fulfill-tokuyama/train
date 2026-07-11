import Foundation

struct Station: Codable, Identifiable, Equatable {
    let name: String
    let reading: String
    var romaji: String?

    var id: String { "\(name)_\(reading)" }

    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.name == rhs.name && lhs.reading == rhs.reading
    }
}

struct TrainLine: Codable, Identifiable {
    let id: String
    let group: String
    let name: String
    let nameReading: String
    let company: String
    let color: String
    let icon: String
    let isLoop: Bool
    let stations: [Station]

    var uniqueStations: [Station] {
        isLoop ? Array(stations.dropLast()) : stations
    }
}

struct LineGroup: Codable, Identifiable {
    let id: String
    let label: String
    let color: String
    let region: String
}

struct TrainData: Codable {
    let groups: [LineGroup]
    let lines: [TrainLine]
}

enum Region: String, CaseIterable {
    case kansai
    case kanto
    case shinkansen

    var displayName: String {
        switch self {
        case .kansai: "かんさい"
        case .kanto: "かんとう"
        case .shinkansen: "しんかんせん"
        }
    }

    var title: String {
        switch self {
        case .kansai: "〜 関西版 〜"
        case .kanto: "〜 関東版 〜"
        case .shinkansen: "〜 新幹線 〜"
        }
    }
}

struct QuizSegment {
    let stations: [Station]
    let blankPos: Int
    let correct: Station
}
