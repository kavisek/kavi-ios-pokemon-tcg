//
//  PokemonCardService.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import Foundation

// MARK: - API Service
@MainActor
class PokemonCardService: ObservableObject {
    @Published var cards: [PokemonCard] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://kavi-api-kavi-sekhon-276359988851.us-central1.run.app/pokemon/cards/"
    
    func fetchCards() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: baseURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch data from server"
                isLoading = false
                return
            }
            
            let cardsResponse = try JSONDecoder().decode(CardsResponse.self, from: data)
            self.cards = cardsResponse.cards
            
        } catch {
            errorMessage = "Failed to decode response: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Function to get cards by set
    func getCards(forSet setId: String) -> [PokemonCard] {
        return cards.filter { $0.setId == setId }
    }
    
    // Function to get unique sets
    var uniqueSets: [String] {
        return Array(Set(cards.map { $0.setId })).sorted()
    }
}
