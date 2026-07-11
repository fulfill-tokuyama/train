import SwiftUI

struct QuizView: View {
    let line: TrainLine
    @StateObject private var vm: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackEmoji: String?

    init(line: TrainLine) {
        self.line = line
        _vm = StateObject(wrappedValue: QuizViewModel(line: line))
    }

    var body: some View {
        ZStack {
            Color(hex: "FFF8EC").ignoresSafeArea()

            if vm.isFinished {
                resultView
            } else {
                quizContent
            }

            if let emoji = feedbackEmoji {
                Text(emoji)
                    .font(.system(size: 80))
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
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
        }
        .onChange(of: vm.answerState) { _, state in
            switch state {
            case .correct:
                showFeedback("🎊")
            case .wrong:
                showFeedback("😢")
            case .waiting:
                break
            }
        }
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: 16) {
            HStack {
                Text(line.name)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: line.color))
                    .clipShape(Capsule())

                Spacer()

                Text("⭐ \(vm.score)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(Color(hex: "E85D3A"))
            }
            .padding(.horizontal)

            Text("\(vm.questionIndex + 1) / \(vm.totalQuestions) もんめ")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)

            if let seg = vm.currentSegment {
                flowCard(segment: seg)
                    .padding(.horizontal)

                HStack(spacing: 12) {
                    ForEach(Array(vm.choices.enumerated()), id: \.element.id) { _, choice in
                        answerButton(choice: choice, segment: seg)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Flow Card

    private func flowCard(segment: QuizSegment) -> some View {
        VStack(spacing: 0) {
            Text("えきの じゅんばん 🚃")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Color(hex: "2C1810"))
                .padding(.bottom, 12)

            ForEach(Array(segment.stations.enumerated()), id: \.offset) { i, station in
                if i > 0 {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: line.color).opacity(0.5))
                        .padding(.vertical, 2)
                }

                if i == segment.blankPos {
                    blankSlot(segment: segment)
                } else {
                    StationSignView(station: station, fontSize: 20)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "F5F0E8"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    @ViewBuilder
    private func blankSlot(segment: QuizSegment) -> some View {
        switch vm.answerState {
        case .waiting:
            Text("❓")
                .font(.system(size: 28))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8]))
                        .foregroundColor(Color(hex: line.color))
                )

        case .correct(let station):
            StationSignView(station: station, fontSize: 20)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color(hex: "D4EDDA"))
                .clipShape(RoundedRectangle(cornerRadius: 10))

        case .wrong(let chosen, let correct):
            VStack(spacing: 4) {
                StationSignView(station: chosen, fontSize: 18)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "F8D7DA"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                HStack(spacing: 4) {
                    Text("→")
                        .foregroundColor(.secondary)
                    StationSignView(station: correct, fontSize: 16)
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Answer Button

    private func answerButton(choice: Station, segment: QuizSegment) -> some View {
        let isCorrectChoice = choice.name == segment.correct.name
        let state = vm.answerState

        return Button {
            vm.answer(choice)
        } label: {
            StationSignView(station: choice, fontSize: 18)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(buttonBackground(isCorrect: isCorrectChoice, state: state))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
        }
        .disabled(state != .waiting)
    }

    private func buttonBackground(isCorrect: Bool, state: QuizViewModel.AnswerState) -> Color {
        switch state {
        case .waiting:
            return .white
        case .correct:
            return isCorrect ? Color(hex: "D4EDDA") : .white
        case .wrong:
            return isCorrect ? Color(hex: "D4EDDA") : Color(hex: "F8D7DA")
        }
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(vm.resultEmoji)
                .font(.system(size: 80))

            Text(vm.resultTitle)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(Color(hex: "2C1810"))

            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Text(i < vm.stars ? "⭐" : "☆")
                        .font(.system(size: 36))
                }
            }

            Text("\(vm.score) / \(vm.totalQuestions)")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(Color(hex: "E85D3A"))

            Text(line.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.top, -8)

            HStack(spacing: 16) {
                Button {
                    vm.retry()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("もういちど")
                    }
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color(hex: "E85D3A"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "house")
                        Text("もどる")
                    }
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color(hex: "0068B7"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            Spacer()
        }
    }

    // MARK: - Feedback

    private func showFeedback(_ emoji: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            feedbackEmoji = emoji
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { feedbackEmoji = nil }
        }
    }
}
