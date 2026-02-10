import SwiftUI

/// Search/guess overlay — text field with debounced autocomplete for actors
struct GuessOverlayView: View {
    @ObservedObject var viewModel: CastingDirectorViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showingGuessOverlay = false
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Text("Who is the actor?")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Button {
                            viewModel.showingGuessOverlay = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Wrong guesses display
                    if !viewModel.roundState.wrongGuesses.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.roundState.wrongGuesses, id: \.self) { name in
                                    Text(name)
                                        .font(.caption)
                                        .strikethrough()
                                        .foregroundStyle(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Search actors...", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isSearchFocused)

                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if viewModel.isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Results list
                    if !viewModel.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(viewModel.searchResults) { actor in
                                    Button {
                                        viewModel.submitGuess(actor)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.fill")
                                                .font(.subheadline)
                                                .foregroundStyle(.indigo)
                                                .frame(width: 30)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(actor.name)
                                                    .font(.body)
                                                    .foregroundStyle(.primary)

                                                if let knownFor = actor.knownFor {
                                                    Text(knownFor)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color(.systemGray6).opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    } else if !viewModel.searchQuery.isEmpty && !viewModel.isSearching {
                        Text("No actors found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                    // Penalty warning
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("Wrong guess: -\(viewModel.difficulty.wrongGuessPenalty) points")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }
}
