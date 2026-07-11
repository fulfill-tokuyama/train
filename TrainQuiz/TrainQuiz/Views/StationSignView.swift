import SwiftUI

struct StationSignView: View {
    let station: Station
    var fontSize: CGFloat = 18

    var body: some View {
        VStack(spacing: 2) {
            Text(station.name)
                .font(.system(size: fontSize, weight: .black))
                .foregroundColor(.primary)

            HStack(spacing: 4) {
                Text(station.reading)
                    .font(.system(size: fontSize * 0.45, weight: .bold))
                    .foregroundColor(.secondary)

                Text(romaji)
                    .font(.system(size: fontSize * 0.42, weight: .semibold))
                    .italic()
                    .foregroundColor(Color(.systemGray))
            }
        }
    }

    private var romaji: String {
        KanaRomaji.capitalizeStation(
            KanaRomaji.toRomaji(station.reading)
        )
    }
}
