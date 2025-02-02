//
//  TriviaView.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 01/02/25.
//

import SwiftUI

struct TriviaView: View {
    @StateObject private var viewModel = TriviaViewModel()
    var body: some View {
        ZStack {
            Image("triviaBackground")
                .resizable()
                .scaledToFill()
                .blur(radius: 10)
                .ignoresSafeArea()
            VStack {
                CategoriesPickerView(viewModel: viewModel)
                    .task {
                        await viewModel.getAllCategories()
                    }
                // 📌 Questions List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<viewModel.questions.count, id: \.self) { index in
                            QuestionView(viewModel: viewModel, questionIndex: index)
                                .padding(.horizontal, 20)
                                .padding(.top, index == 0 ? 10 : 0)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct CategoriesPickerView: View {
    @ObservedObject var viewModel: TriviaViewModel

    var body: some View {
        VStack(spacing: 20) {
            // 🏷️ Category Picker
            Menu {
                Picker("Choose Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category.name)
                            .tag(category)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedCategory?.name ?? "Choose Category")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.cornerRadius(12))
                .shadow(radius: 4)
            }
            .padding(.horizontal, 20)
            .onChange(of: viewModel.selectedCategory) {
                Task {
                    try await viewModel.getQuestions()
                }
            }
        }
        .padding(.vertical, 30)
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct QuestionView: View {
    @ObservedObject var viewModel: TriviaViewModel
    let questionIndex: Int
    
    var question: Question {
        viewModel.questions[questionIndex]
    }

    private var allAnswers: [String] {
        let answers = question.incorrectAnswers + [question.correctAnswer]
        return answers.shuffled()
    }

    private var questionText: String {
        question.question
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 🏷️ Question Text
            Text(questionText)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 📌 Answer Choices
//            LazyVStack(spacing: 12) {
                ForEach(allAnswers, id: \.self) { answer in
                    Button(action: {
                        // Handle answer selection
                    }) {
                        Text(answer)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.system(size: 18, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .simultaneousGesture(TapGesture())
                }
//            }
            
            Spacer()
        }
        .padding(.vertical, 30)
    }
}

#Preview {
    TriviaView()
}
