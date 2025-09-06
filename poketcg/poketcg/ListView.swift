//
//  ListView.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import SwiftUI

struct ListView: View {
    @StateObject private var cardService = PokemonCardService()

    var body: some View {
        NavigationView {
            // Cards list
            List {
                ForEach(filteredCards) { card in
                    NavigationLink {
                        PokemonCardDetailView(card: card)
                    } label: {
                        PokemonCardRowView(card: card)
                    }
                }
            }
            .refreshable {
                await cardService.fetchCards()
            }
            .navigationTitle("All Cards")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        Task {
                            await cardService.fetchCards()
                        }
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(cardService.isLoading)
                }
            }
        }
        .task {
            if cardService.cards.isEmpty {
                await cardService.fetchCards()
            }
        }
        .overlay {
            if cardService.isLoading {
                ProgressView("Loading Pokemon Cards...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
        .alert("Error", isPresented: .constant(cardService.errorMessage != nil)) {
            Button("OK") {
                cardService.errorMessage = nil
            }
        } message: {
            Text(cardService.errorMessage ?? "")
        }
    }
    
    private var filteredCards: [PokemonCard] {
        return cardService.cards
    }
}

#Preview {
    ListView()
}
