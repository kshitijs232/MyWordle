//
//  CharGridView.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 19/01/25.
//

import SwiftUI
import UIKit

struct CharGridView: View {
    @StateObject private var viewModel = CharGridViewModel()
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("wordleBackground") // Matches the name of the image in the asset catalog
                .resizable()
                .scaledToFill() // Ensures it fills the screen
                .blur(radius: 10)
                .ignoresSafeArea()
            VStack {
                Label("Total Streak: \(viewModel.totalScore)", systemImage: "trophy.fill")
                ForEach(viewModel.rows.indices, id: \.self) { rowIndex in
                    RowView(viewModel: viewModel, rowIndex: rowIndex)
                }
                Button("Submit") {
                    viewModel.validateWord()
                }
                .frame(width: 300, height: 50)
                .background(Color.green) // Dim color when pressed
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(40)
                .disabled(viewModel.currentWord.count<5)
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    viewModel.resetGrid()
                }
            }
        }
    }

struct RowView: View {
    @ObservedObject var viewModel : CharGridViewModel
    let rowIndex: Int

    var body: some View {
        HStack {
            ForEach(viewModel.rows[rowIndex].cells.indices, id: \.self) { colIndex in
                CellView(viewModel: viewModel, cell: $viewModel.rows[rowIndex].cells[colIndex])
            }
        }
    }
}

struct CellView : View {
    @ObservedObject var viewModel : CharGridViewModel
    @Binding var cell: CellData
    
    var body: some View {
        TextField("", text: $cell.char)
            .font(.system(size: 26))
            .fontWeight(.bold)
            .frame(width: 50, height: 50)
            .background(cell.cellState.color)
            .clipShape(Rectangle())
            .border(.primary)
            .multilineTextAlignment(.center)
            .onChange(of: cell.char) { oldValue, newValue in
                viewModel.rowIndex = cell.row
                viewModel.colIndex = cell.column
                if newValue.count > 1 {
                    cell.char = oldValue
                }
            }
            .disabled(cell.visited)
        }
    }
}


enum CellState {
    case unevaluated
    case doesnotExist
    case existsButInWrongPos
    case existsAndInRightPos
    
    var color: Color {
        switch self {
        case .unevaluated:
            return Color.clear
        case .doesnotExist:
            return Color.gray
        case .existsButInWrongPos:
            return Color.yellow
        case .existsAndInRightPos:
            return Color.green
        }
    }
}

#Preview {
    CharGridView()
}
