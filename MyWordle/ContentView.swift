//
//  ContentView.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 19/01/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Wordle", destination: CharGridView())
                NavigationLink("Trivia", destination: TriviaView())
            }
        }
    }
}

#Preview {
    ContentView()
}
