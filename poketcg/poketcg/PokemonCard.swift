//
//  PokemonCard.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import Foundation

// MARK: - Pokemon Card Models
struct PokemonCard: Codable, Identifiable, Hashable {
    let id: String
    let setId: String
    let language: String
    let cardNumber: String
    let variant: String
    let filename: String
    let fileSizeBytes: Int

    enum CodingKeys: String, CodingKey {
        case id = "card_id"
        case setId = "set_id"
        case language
        case cardNumber = "card_number"
        case variant
        case filename
        case fileSizeBytes = "file_size_bytes"
    }

    // Computed property for display
    var displayName: String {
        return "\(setId.uppercased()) #\(cardNumber)"
    }

    // Computed property for image URL using card_id
    var imageURL: String {
        return "https://kavi-api-kavi-sekhon-276359988851.us-central1.run.app/pokemon/cards/\(id)"
    }
}

// MARK: - API Response Model
struct CardsResponse: Codable {
    let cards: [PokemonCard]
    let totalCount: Int
    let setsSummary: [String: Int]
    let directoryPath: String

    enum CodingKeys: String, CodingKey {
        case cards
        case totalCount = "total_count"
        case setsSummary = "sets_summary"
        case directoryPath = "directory_path"
    }
}
