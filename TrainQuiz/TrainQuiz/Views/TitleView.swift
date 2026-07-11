import SwiftUI

struct TitleView: View {
    let onStartQuiz: (TrainLine) -> Void
    let onShowRoute: (TrainLine) -> Void
    let onSearch: () -> Void

    @State private var region: Region = .kansai
    @State private var mode: AppMode = .quiz
    @State private var expandedGroups: Set<String> = []

    private let loader = DataLoader.shared

    enum AppMode {
        case quiz, routeMap
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "87CEEB"), Color(hex: "B6E3F4"), Color(hex: "FFF8EC")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    regionPicker
                    modePicker
                    searchButton
                    lineList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            }

            groundView
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("🚃")
                .font(.system(size: 60))
                .padding(.top, 20)

            Text("つぎのえきは？")
                .font(.system(size: 22, weight: .black))
                .foregroundColor(Color(hex: "2C1810"))

            Text(region.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "E85D3A"))

            Text("でんしゃクイズ")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(hex: "E85D3A"))
                .tracking(2)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Region Picker

    private var regionPicker: some View {
        HStack(spacing: 0) {
            ForEach(Region.allCases, id: \.self) { r in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { region = r }
                } label: {
                    Text(r.displayName)
                        .font(.system(size: 14, weight: .black))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(region == r ? Color(hex: "0068B7") : .white)
                        .foregroundColor(region == r ? .white : Color(.systemGray))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation { mode = .quiz }
            } label: {
                HStack(spacing: 4) {
                    Text("🎯")
                    Text("えきめいクイズ")
                }
                .font(.system(size: 16, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(mode == .quiz ? Color(hex: "E85D3A") : .white)
                .foregroundColor(mode == .quiz ? .white : Color(.systemGray))
            }

            Button {
                withAnimation { mode = .routeMap }
            } label: {
                HStack(spacing: 4) {
                    Text("📋")
                    Text("ろせんず")
                }
                .font(.system(size: 16, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(mode == .routeMap ? Color(hex: "E85D3A") : .white)
                .foregroundColor(mode == .routeMap ? .white : Color(.systemGray))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    // MARK: - Search Button

    private var searchButton: some View {
        Button(action: onSearch) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("えきをさがす")
            }
            .font(.system(size: 16, weight: .black))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color(hex: "3A7BE8"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
    }

    // MARK: - Line List

    private var lineList: some View {
        let groups = loader.groups(for: region)
        return LazyVStack(spacing: 14) {
            ForEach(groups) { group in
                companySection(group: group)
            }
        }
    }

    private func companySection(group: LineGroup) -> some View {
        let groupLines = loader.lines(for: group)
        let isExpanded = expandedGroups.contains(group.id)

        return VStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded {
                        expandedGroups.remove(group.id)
                    } else {
                        expandedGroups.insert(group.id)
                    }
                }
            } label: {
                HStack {
                    Text(group.label)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: group.color))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }

            if isExpanded {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    ForEach(groupLines) { line in
                        lineButton(line: line)
                    }
                }
                .padding(.horizontal, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func lineButton(line: TrainLine) -> some View {
        Button {
            if mode == .quiz {
                onStartQuiz(line)
            } else {
                onShowRoute(line)
            }
        } label: {
            VStack(spacing: 2) {
                Text(line.icon)
                    .font(.system(size: 22))
                Text(line.name)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .foregroundColor(.white)
            .background(Color(hex: line.color))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
        }
    }

    // MARK: - Ground

    private var groundView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(hex: "8B6914"))
                .frame(height: 10)
            LinearGradient(
                colors: [Color(hex: "7EC850"), Color(hex: "5BA03A")],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 40)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
