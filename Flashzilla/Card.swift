//
//  Card.swift
//  Flashzilla
//
//  Created by Chloe Fermanis on 10/10/20.
//

import Foundation

struct Card: Codable {
    let prompt: String
    let answer: String

    static var example: Card {
        Card(prompt: "Who directed Parasite?", answer: "Bong Joon-ho")
    }
}
