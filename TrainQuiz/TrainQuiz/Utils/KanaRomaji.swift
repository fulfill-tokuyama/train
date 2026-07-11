import Foundation

enum KanaRomaji {
    private static let yoon: [String: String] = [
        "きゃ": "kya", "きゅ": "kyu", "きょ": "kyo",
        "ぎゃ": "gya", "ぎゅ": "gyu", "ぎょ": "gyo",
        "しゃ": "sha", "しゅ": "shu", "しょ": "sho",
        "じゃ": "ja", "じゅ": "ju", "じょ": "jo",
        "ちゃ": "cha", "ちゅ": "chu", "ちょ": "cho",
        "ぢゃ": "ja", "ぢゅ": "ju", "ぢょ": "jo",
        "にゃ": "nya", "にゅ": "nyu", "にょ": "nyo",
        "ひゃ": "hya", "ひゅ": "hyu", "ひょ": "hyo",
        "びゃ": "bya", "びゅ": "byu", "びょ": "byo",
        "ぴゃ": "pya", "ぴゅ": "pyu", "ぴょ": "pyo",
        "みゃ": "mya", "みゅ": "myu", "みょ": "myo",
        "りゃ": "rya", "りゅ": "ryu", "りょ": "ryo",
        "てぃ": "ti", "でぃ": "di",
        "ふぁ": "fa", "ふぃ": "fi", "ふぇ": "fe", "ふぉ": "fo",
    ]

    private static let rom: [Character: String] = [
        "あ": "a", "い": "i", "う": "u", "え": "e", "お": "o",
        "か": "ka", "き": "ki", "く": "ku", "け": "ke", "こ": "ko",
        "が": "ga", "ぎ": "gi", "ぐ": "gu", "げ": "ge", "ご": "go",
        "さ": "sa", "し": "shi", "す": "su", "せ": "se", "そ": "so",
        "ざ": "za", "じ": "ji", "ず": "zu", "ぜ": "ze", "ぞ": "zo",
        "た": "ta", "ち": "chi", "つ": "tsu", "て": "te", "と": "to",
        "だ": "da", "ぢ": "ji", "づ": "zu", "で": "de", "ど": "do",
        "な": "na", "に": "ni", "ぬ": "nu", "ね": "ne", "の": "no",
        "は": "ha", "ひ": "hi", "ふ": "fu", "へ": "he", "ほ": "ho",
        "ば": "ba", "び": "bi", "ぶ": "bu", "べ": "be", "ぼ": "bo",
        "ぱ": "pa", "ぴ": "pi", "ぷ": "pu", "ぺ": "pe", "ぽ": "po",
        "ま": "ma", "み": "mi", "む": "mu", "め": "me", "も": "mo",
        "や": "ya", "ゆ": "yu", "よ": "yo",
        "ら": "ra", "り": "ri", "る": "ru", "れ": "re", "ろ": "ro",
        "わ": "wa", "を": "o", "ん": "n",
        "ー": "-",
    ]

    private static let mSet: Set<Character> = Set("まみむめもばびぶべぼぱぴぷぺぽ")

    static func toHiragana(_ str: String) -> String {
        String(str.unicodeScalars.map { scalar in
            if scalar.value >= 0x30A1 && scalar.value <= 0x30F6 {
                return Character(UnicodeScalar(scalar.value - 0x60)!)
            }
            return Character(scalar)
        })
    }

    static func toRomaji(_ reading: String) -> String {
        let str = Array(toHiragana(reading))
        var result = ""
        var i = 0

        while i < str.count {
            if str[i] == "っ" {
                i += 1
                if i < str.count {
                    if let twoChar = yoonLookup(str, i) {
                        result += String(twoChar.first!)
                        result += twoChar
                        i += 2
                    } else if let r = rom[str[i]] {
                        result += String(r.first!)
                        result += r
                        i += 1
                    } else {
                        result += "t"
                        i += 1
                    }
                }
                continue
            }

            if let twoChar = yoonLookup(str, i) {
                result += twoChar
                i += 2
                continue
            }

            if str[i] == "ん" {
                if i + 1 < str.count && mSet.contains(str[i + 1]) {
                    result += "m"
                } else {
                    result += "n"
                }
                i += 1
                continue
            }

            if let r = rom[str[i]] {
                result += r
            }
            i += 1
        }

        return result
    }

    private static func yoonLookup(_ chars: [Character], _ i: Int) -> String? {
        guard i + 1 < chars.count else { return nil }
        let key = String(chars[i...i+1])
        return yoon[key]
    }

    static func capitalizeStation(_ romaji: String) -> String {
        romaji.split(separator: "-")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: "-")
    }
}
