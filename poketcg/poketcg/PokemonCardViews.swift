//
//  PokemonCardViews.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import SwiftUI

// MARK: - Card Row View
struct PokemonCardRowView: View {
    let card: PokemonCard

    var body: some View {
        HStack {
            // Card image placeholder
            AsyncImage(url: URL(string: card.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }
            .frame(width: 60, height: 84)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Set: \(card.setId.uppercased())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Card #\(card.cardNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if card.variant != "std" {
                    Text("Variant: \(card.variant.uppercased())")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(card.language.uppercased())
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)

                Text(formatFileSize(card.fileSizeBytes))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Card Detail View
struct PokemonCardDetailView: View {
    let card: PokemonCard

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Full Screen Card Image
                    AsyncImage(url: URL(string: card.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("Loading...")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                            }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)
                    .clipped()

                    // Card Details Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text(card.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Group {
                                DetailRow(title: "Card ID", value: card.id)
                                DetailRow(title: "Set", value: card.setId.uppercased())
                                DetailRow(title: "Card Number", value: card.cardNumber)
                                DetailRow(title: "Language", value: card.language.uppercased())
                                DetailRow(title: "Variant", value: card.variant.uppercased())
                                DetailRow(title: "Filename", value: card.filename)
                                DetailRow(title: "File Size", value: formatFileSize(card.fileSizeBytes))
                            }
                        }

                        // Extra spacing at the bottom
                        Spacer()
                            .frame(height: 50)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Detail Row Helper View
struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.regular)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Previews
#Preview("Card Row") {
    List {
        PokemonCardRowView(card: PokemonCard(
            id: "sv10_en_001_std",
            setId: "sv10",
            language: "en",
            cardNumber: "001",
            variant: "std",
            filename: "sv10_en_001_std.jpg",
            fileSizeBytes: 203466
        ))
    }
}

#Preview("Card Detail") {
    NavigationView {
        PokemonCardDetailView(card: PokemonCard(
            id: "sv10_en_001_std",
            setId: "sv10",
            language: "en",
            cardNumber: "001",
            variant: "std",
            filename: "sv10_en_001_std.jpg",
            fileSizeBytes: 203466
        ))
    }
}
