//
//  LetterTilesView.swift
//  BorderBlitz
//

import SwiftUI

struct BorderBlitzLetterTilesView: View {
    let tiles: [BorderBlitzLetterTile]

    var body: some View {
        VStack(spacing: 8) {
            // Split into lines if there are spaces
            let lines = splitIntoLines(tiles)

            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(spacing: 4) {
                    ForEach(line) { tile in
                        BorderBlitzLetterTileView(tile: tile)
                    }
                }
            }
        }
        .padding()
    }

    private func splitIntoLines(_ tiles: [BorderBlitzLetterTile]) -> [[BorderBlitzLetterTile]] {
        var lines: [[BorderBlitzLetterTile]] = []
        var currentLine: [BorderBlitzLetterTile] = []

        for tile in tiles {
            if tile.character == " " {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = []
                }
            } else {
                currentLine.append(tile)
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        return lines.isEmpty ? [[]] : lines
    }
}

struct BorderBlitzLetterTileView: View {
    let tile: BorderBlitzLetterTile

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tile.shouldDisplay ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: 35, height: 45)

            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                .frame(width: 35, height: 45)

            if tile.shouldDisplay {
                Text(String(tile.character).uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Text("_")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}
