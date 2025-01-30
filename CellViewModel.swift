//
//  CellViewModel.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 19/01/25.
//


import Foundation

struct CellData {
    var char: String
    var cellState: CellState = .unevaluated
    let id: String
    var row: Int
    var column: Int
    var visited: Bool = false
}
