//
//  TriviaViewModel.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 01/02/25.
//

import Foundation

final class TriviaViewModel: ObservableObject {
    var difficulty: [String]?
    
    @Published var selectedCategory: TriviaCategory?
    @Published var categories: [TriviaCategory] = []
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    
    let networkManager: NetworkManager
    let baseUrlPath = "https://opentdb.com"
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else {
            return nil
        }
        return questions[currentQuestionIndex]
    }
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getAllCategories() async {
        let request = networkManager.createRequest(url: URL(string: "\(baseUrlPath)/api_category.php")!, method: .GET, body: nil)
        let data = await networkManager.makeRequest(request: request)
        do {
            guard let data = data else {
                print("No data returned")
                return
            }
            let categoriesResponse = try JSONDecoder().decode(CategoriesResponse.self, from: data)
            await MainActor.run {
                self.categories = categoriesResponse.triviaCategories
                self.selectedCategory = self.categories.first
            }
        } catch {
            print("Failed in decoding categories \(error)")
        }
        return
    }

    func getQuestions() async throws {
        guard let selectedCategory = selectedCategory else {
            print("No category selected")
            return
        }
        let request = networkManager.createRequest(url: URL(string: "\(baseUrlPath)/api.php?amount=10&category=\(selectedCategory.id)&difficulty=medium&type=multiple")!, method: .GET, body: nil)
        let data = await networkManager.makeRequest(request: request)
        do {
            guard let data = data else {
                print("No data returned")
                return
            }
            let questionResponse = try JSONDecoder().decode(QuestionResponse.self, from: data)
            await MainActor.run {
                self.questions = questionResponse.results
            }
        } catch {
            print("Failed in decoding questions \(error)")
        }
        
    }
}

struct CategoriesResponse: Decodable {
    let triviaCategories: [TriviaCategory]
    
    enum CodingKeys: String, CodingKey {
        case triviaCategories = "trivia_categories"
    }
}

struct TriviaCategory: Decodable, Hashable {
    let id: Int
    let name: String
}

struct QuestionResponse: Decodable {
    let responseCode: Int
    let results: [Question]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct Question: Decodable, Hashable {
    let category: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let difficulty: String
    let question: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case category
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case difficulty
        case question
        case type
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            category = try container.decode(String.self, forKey: .category)
            correctAnswer = try container.decode(String.self, forKey: .correctAnswer).decodedHTML
            incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers).map { $0.decodedHTML }
            difficulty = try container.decode(String.self, forKey: .difficulty)
            question = try container.decode(String.self, forKey: .question).decodedHTML
            type = try container.decode(String.self, forKey: .type)
        }
}


extension String {
    var decodedHTML: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil).string) ?? self
    }
}
