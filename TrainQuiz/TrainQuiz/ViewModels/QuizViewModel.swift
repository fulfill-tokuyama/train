import Foundation
import Combine

final class QuizViewModel: ObservableObject {
    @Published var segments: [QuizSegment] = []
    @Published var questionIndex = 0
    @Published var score = 0
    @Published var choices: [Station] = []
    @Published var answerState: AnswerState = .waiting
    @Published var isFinished = false

    let line: TrainLine
    private let quizLength = 10

    enum AnswerState: Equatable {
        case waiting
        case correct(Station)
        case wrong(chosen: Station, correct: Station)
    }

    init(line: TrainLine) {
        self.line = line
        generateQuiz()
    }

    var currentSegment: QuizSegment? {
        guard questionIndex < segments.count else { return nil }
        return segments[questionIndex]
    }

    var totalQuestions: Int { segments.count }

    var resultEmoji: String {
        let pct = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        if pct == 1 { return "🏆" }
        if pct >= 0.8 { return "🎉" }
        if pct >= 0.5 { return "😊" }
        return "💪"
    }

    var resultTitle: String {
        let pct = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        if pct == 1 { return "パーフェクト！！" }
        if pct >= 0.8 { return "すごーい！" }
        if pct >= 0.5 { return "がんばったね！" }
        return "つぎはがんばろう！"
    }

    var stars: Int {
        let pct = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        if pct == 1 { return 3 }
        if pct >= 0.7 { return 2 }
        if pct >= 0.4 { return 1 }
        return 0
    }

    func generateQuiz() {
        let u = line.uniqueStations
        guard u.count >= 3 else { return }

        var result: [QuizSegment] = []
        let numQ = min(quizLength, u.count - 2)
        var usedBlanks: Set<Int> = []
        var attempts = 0

        while result.count < numQ && attempts < 200 {
            attempts += 1
            let winSize = min(3 + Int.random(in: 0...2), u.count)
            guard winSize >= 3 else { continue }
            let maxStart = u.count - winSize
            let start = Int.random(in: 0...maxStart)
            let blankPos = 1 + Int.random(in: 0..<(winSize - 2))
            let blankAbsIdx = start + blankPos

            guard !usedBlanks.contains(blankAbsIdx) else { continue }
            usedBlanks.insert(blankAbsIdx)

            let segment = Array(u[start..<start + winSize])
            result.append(QuizSegment(
                stations: segment,
                blankPos: blankPos,
                correct: segment[blankPos]
            ))
        }

        segments = result
        questionIndex = 0
        score = 0
        answerState = .waiting
        isFinished = false
        generateChoices()
    }

    func generateChoices() {
        guard let seg = currentSegment else { return }
        let wrong = pickWrongStation(correct: seg.correct)
        var c = [seg.correct, wrong]
        c.shuffle()
        choices = c
    }

    func answer(_ chosen: Station) {
        guard answerState == .waiting, let seg = currentSegment else { return }

        if chosen.name == seg.correct.name {
            score += 1
            answerState = .correct(seg.correct)
            SoundManager.shared.playCorrect()
        } else {
            answerState = .wrong(chosen: chosen, correct: seg.correct)
            SoundManager.shared.playWrong()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.nextQuestion()
        }
    }

    private func nextQuestion() {
        questionIndex += 1
        if questionIndex >= segments.count {
            isFinished = true
            SoundManager.shared.playResult()
        } else {
            answerState = .waiting
            generateChoices()
        }
    }

    func retry() {
        generateQuiz()
    }

    private func pickWrongStation(correct: Station) -> Station {
        let all = line.uniqueStations
        for _ in 0..<100 {
            let r = all.randomElement()!
            if r.name != correct.name { return r }
        }
        return all[0]
    }
}
