//
//  CharGridViewModel.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 19/01/25.
//

import Foundation

class CharGridViewModel : ObservableObject {
    @Published var rows: [RowData] = []
    @Published var expectedWord: String = ""
    @Published var showAlert: Bool = false

    var allPopularWords:  [String] = []
    var allPossibleWords: Set<String> = []
    var shownWords: Set<String> = []
    var alertTitle: String = ""
    var totalScore: Int = UserDefaults.standard.integer(forKey: "totalScore")

    var rowIndex: Int = 0 {
        didSet {
            print("rowIndex: \(rowIndex)")
        }
    }

    var colIndex: Int = 0 {
        didSet {
            print("colIndex: \(colIndex)")
            if colIndex == 4 {
                print("currentWord: \(currentWord)")
            }
        }
    }

    var currentWord: String {
        var currentWord: String = ""
        for cell in rows[rowIndex].cells {
            currentWord.append(cell.char)
        }
        return currentWord
    }

    var matched: Bool {
        currentWord == expectedWord
    }

    init() {
        allPopularWords = loadPopularFiveLetterWords()
        allPossibleWords = loadAllFiveLetterWords()
        expectedWord = allPopularWords.randomElement()?.uppercased() ?? "WEIRD"
        shownWords.insert(expectedWord)
        print("expectedWord: \(expectedWord)")

        for i in 0..<6 {
            var newRow: RowData = RowData(id: UUID().uuidString, cells: [])
            for j in 0..<5 {
                newRow.cells.append(CellData(char: "", id: UUID().uuidString, row: i, column: j))
            }
            rows.append(newRow)
        }
    }

    func loadPopularFiveLetterWords() -> [String] {
        var words: [String] = []
        // Get the URL for the file in the app bundle
        if let fileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            do {
                // Read the file content into a string
                let fileContents = try String(contentsOf: fileURL)
                
                // Split the content by new lines to get individual words
                words = fileContents.split(separator: "\n").map { String($0) }
                
            } catch {
                print("Error loading file: \(error.localizedDescription)")
            }
        } else {
            print("File not found in bundle.")
        }
//        print(fiveLetterWords)
        return words
    }

    func loadAllFiveLetterWords() -> Set<String> {
        var words: Set<String> = []
        if let fileURL = Bundle.main.url(forResource: "allwords", withExtension: "txt") {
            do {
                let fileContents = try String(contentsOf: fileURL)
                words = Set(fileContents.split(separator: "\n").map { String($0).uppercased() }.filter { $0.count == 5 } )
            }
            catch {
                print("Error loading file: \(error.localizedDescription)")
            }
        }
        return words
    }

    func validateWord() {
        guard allPossibleWords.contains(currentWord) else { return }
        print("currentWord: \(currentWord) and rowIndex: \(rowIndex)")
        guard currentWord.count == 5 else { return }
        
        if !matched && rowIndex == 5 {
            alertTitle = "Game Over! The word was: \(expectedWord)"
            showAlert = true
            totalScore = 0
            return
        }
        
        // Step 1: Create a frequency map for the expected word
        var expectedWordFrequency: [Character: Int] = [:]
        for char in expectedWord {
            expectedWordFrequency[char, default: 0] += 1
        }
        
        // Step 2: First pass - Check for correct position matches
        for j in 0..<5 {
            rows[rowIndex].cells[j].visited = true
            let currentChar = rows[rowIndex].cells[j].char
            
            if currentChar == String(expectedWord[expectedWord.index(expectedWord.startIndex, offsetBy: j)]) {
                rows[rowIndex].cells[j].cellState = .existsAndInRightPos
                expectedWordFrequency[Character(currentChar)]? -= 1 // Decrease available count for this character
            }
        }
        
        // Step 3: Second pass - Check for wrong position matches
        for j in 0..<5 {
            let currentChar = rows[rowIndex].cells[j].char
            
            // Skip already matched cells
            if rows[rowIndex].cells[j].cellState == .existsAndInRightPos {
                continue
            }
            
            if let remainingCount = expectedWordFrequency[Character(currentChar)], remainingCount > 0 {
                rows[rowIndex].cells[j].cellState = .existsButInWrongPos
                expectedWordFrequency[Character(currentChar)]? -= 1 // Decrease available count for this character
            } else {
                rows[rowIndex].cells[j].cellState = .doesnotExist
            }
        }
        
        if matched {
            alertTitle = "Correct!"
            showAlert = true
            totalScore += 1
            UserDefaults.standard.set(totalScore, forKey: "totalScore")
        }
    }

    
    func resetGrid() {
        expectedWord = allPopularWords.randomElement()?.uppercased() ?? "WEIRD"
        while (shownWords.contains(expectedWord)) {
            expectedWord = allPopularWords.randomElement()?.uppercased() ?? "WEIRD"
        }

        for i in 0..<6 {
            for j in 0..<5 {
                rows[i].cells[j].visited = false
                rows[i].cells[j].cellState = .unevaluated
                rows[i].cells[j].char = ""
            }
        }
    }
}
