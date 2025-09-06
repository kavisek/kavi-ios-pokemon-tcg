//
//  SearchView.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var cardService = PokemonCardService()
    @State private var searchText = ""
    @State private var selectedSet = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search controls
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search cards...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Set filter
                    if !cardService.uniqueSets.isEmpty {
                        HStack {
                            Text("Filter by Set:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Set", selection: $selectedSet) {
                                Text("All Sets").tag("")
                                ForEach(cardService.uniqueSets, id: \.self) { set in
                                    Text(set.uppercased()).tag(set)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Results list
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
            }
            .navigationTitle("Search")
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
            if cardService.isLoading && cardService.cards.isEmpty {
                ProgressView("Loading Pokemon Cards...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            } else if filteredCards.isEmpty && !searchText.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No cards found")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Try adjusting your search terms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        var cards = cardService.cards
        
        // Filter by set if selected
        if !selectedSet.isEmpty {
            cards = cards.filter { $0.setId == selectedSet }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            cards = cards.filter { card in
                card.displayName.localizedCaseInsensitiveContains(searchText) ||
                card.id.localizedCaseInsensitiveContains(searchText) ||
                card.setId.localizedCaseInsensitiveContains(searchText) ||
                card.cardNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return cards
    }
}

#Preview {
    SearchView()
}
