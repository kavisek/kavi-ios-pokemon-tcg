//
//  FeedView.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var cardService = PokemonCardService()
    @State private var shuffledCards: [PokemonCard] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(shuffledCards) { card in
                    NavigationLink {
                        PokemonCardDetailView(card: card)
                    } label: {
                        PokemonCardRowView(card: card)
                    }
                }
            }
            .refreshable {
                await loadAndShuffleCards()
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        Task {
                            await loadAndShuffleCards()
                        }
                    }) {
                        Label("Shuffle", systemImage: "shuffle")
                    }
                    .disabled(cardService.isLoading)
                }
            }
        }
        .task {
            if cardService.cards.isEmpty {
                await cardService.fetchCards()
            }
            shuffleCards()
        }
        .onChange(of: cardService.cards) { _ in
            shuffleCards()
        }
        .overlay {
            if cardService.isLoading && shuffledCards.isEmpty {
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
    
    private func shuffleCards() {
        shuffledCards = cardService.cards.shuffled()
    }
    
    private func loadAndShuffleCards() async {
        await cardService.fetchCards()
        shuffleCards()
    }
}

#Preview {
    FeedView()
}
