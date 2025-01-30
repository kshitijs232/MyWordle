//
//  RowViewModel.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 19/01/25.
//
import Foundation

class RowViewModel : ObservableObject {
    var row: RowData?
}

struct RowData {
    let id: String
    var cells: [CellData]
}
