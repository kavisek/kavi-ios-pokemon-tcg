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
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Card Image Container with proper spacing
                    ZStack {
                        // Black background for full screen
                        Color.black

                        VStack {
                            // Top spacer for navigation bar
                            Spacer()
                                .frame(height: 60)

                            // Zoomable card image
                            ZStack {
                                AsyncImage(url: URL(string: card.imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(scale)
                                        .offset(offset)
                                        .padding(.horizontal, 20)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay {
                                            VStack(spacing: 12) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 60))
                                                    .foregroundColor(.gray)
                                                Text("Loading...")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .scaleEffect(scale)
                                        .offset(offset)
                                        .padding(.horizontal, 20)
                                }

                                // Metallic shimmer overlay
                                MetalShineOverlay()
                                    .scaleEffect(scale)
                                    .offset(offset)
                                    .padding(.horizontal, 20)
                            }
                            .clipped()
                            .gesture(
                                SimultaneousGesture(
                                    // Magnification gesture for zoom
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            let newScale = scale * delta
                                            scale = min(max(newScale, 0.5), 3.0) // Limit zoom between 0.5x and 3x
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            // Snap back if zoomed out too much
                                            if scale < 1.0 {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    scale = 1.0
                                                    offset = .zero
                                                }
                                            }
                                        },

                                    // Drag gesture for panning when zoomed
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = newOffset
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                            )
                            .onTapGesture(count: 2) {
                                // Double tap to reset zoom
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }

                            // Bottom spacer for centering
                            Spacer()
                                .frame(height: 60)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                    // Card Details Section with improved spacing
                    VStack(alignment: .leading, spacing: 0) {
                        // Header section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(card.displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("Card Details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 24)

                        // Details grid
                        VStack(alignment: .leading, spacing: 20) {
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

                        // Bottom spacing for comfortable scrolling
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.horizontal, 24)
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
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(value)
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Metal Shine Overlay
struct MetalShineOverlay: View {
    @State private var moveGradient = false
    @State private var animationTimer: Timer?

    var body: some View {
        // Metallic shimmer overlay
        LinearGradient(
            gradient: Gradient(colors: [
                .white.opacity(0.1),
                .white.opacity(0.6),
                .white.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.overlay) // this makes it look metallic
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white, .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: moveGradient ? 300 : -300)
        )
        .animation(
            Animation.linear(duration: 2.0),
            value: moveGradient
        )
        .onAppear {
            startAnimationCycle()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }

    private func startAnimationCycle() {
        // Start the first animation
        moveGradient = true

        // Set up timer to restart animation after pause
        animationTimer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true) { _ in
            // Reset position and animate again
            moveGradient = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                moveGradient = true
            }
        }
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
