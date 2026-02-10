import Foundation

/// Generates ordered clues for a target actor by querying MovieChainDatabase
final class ClueGenerator {
    private let database = MovieChainDatabase.shared

    // MARK: - Big Actor Pool

    /// Cached list of qualifying actor nconst IDs (5+ movies, 3+ with 50k+ votes)
    private static var qualifiedActorIds: [String]?
    private static var usedActorIdsThisSession: Set<String> = []

    /// Build or return the cached pool of "big actors"
    func getQualifiedActors() -> [String] {
        if let cached = Self.qualifiedActorIds {
            return cached
        }

        // Check UserDefaults cache first
        if let cached = UserDefaults.standard.array(forKey: "casting_director_qualified_actors") as? [String], !cached.isEmpty {
            Self.qualifiedActorIds = cached
            return cached
        }

        // Query the database for qualifying actors
        let ids = buildQualifiedActorPool()
        Self.qualifiedActorIds = ids
        UserDefaults.standard.set(ids, forKey: "casting_director_qualified_actors")
        return ids
    }

    private func buildQualifiedActorPool() -> [String] {
        guard database.isLoaded else { return [] }

        // Single efficient SQL query: actors with 5+ movies, 3+ having 50k+ votes
        let qualified = database.getQualifiedActorIds(minMovies: 5, minHighVoteMovies: 3, minVotes: 50000)
        print("ClueGenerator: Found \(qualified.count) qualified actors")
        return qualified
    }

    /// Reset session tracking (call when starting a new game session)
    func resetSession() {
        Self.usedActorIdsThisSession.removeAll()
    }

    /// Pick a random actor from the qualified pool, avoiding recent repeats
    func pickRandomActor() -> Actor? {
        let pool = getQualifiedActors()
        let available = pool.filter { !Self.usedActorIdsThisSession.contains($0) }

        // If we've used all actors, reset
        let candidates = available.isEmpty ? pool : available

        guard let randomId = candidates.randomElement() else { return nil }
        Self.usedActorIdsThisSession.insert(randomId)
        return database.getActor(byId: randomId)
    }

    // MARK: - Clue Generation

    /// Generate an ordered array of clues for the given actor, respecting difficulty settings
    func generateClues(for actor: Actor, difficulty: CastingDirectorDifficulty) -> [Clue] {
        let movies = database.getMoviesWithActor(actorId: actor.nconst)
        guard !movies.isEmpty else { return [] }

        var clues: [Clue] = []
        var orderNumber = 1

        // Collect all directors and co-stars
        var allDirectors: [(director: Director, movie: Movie)] = []
        var allCoStars: [Actor] = []
        var coStarSeen: Set<String> = [actor.nconst]

        let qualifiedPool = Set(getQualifiedActors())

        for movie in movies {
            let directors = database.getDirectorsOfMovie(movieId: movie.tconst)
            for director in directors {
                allDirectors.append((director: director, movie: movie))
            }

            // Only gather co-stars from top movies (by votes) for efficiency
            if (movie.votes ?? 0) >= 20000 {
                let actors = database.getActorsInMovie(movieId: movie.tconst)
                for coStar in actors {
                    if !coStarSeen.contains(coStar.nconst) {
                        coStarSeen.insert(coStar.nconst)
                        // Prefer recognizable co-stars (in the qualified pool)
                        if qualifiedPool.contains(coStar.nconst) {
                            allCoStars.append(coStar)
                        }
                    }
                }
            }
        }

        // Compute aggregates
        let totalMovieCount = movies.count
        let genreFrequency = computeGenreFrequency(movies: movies)
        let sortedGenres = genreFrequency.sorted { $0.value > $1.value }
        let mostActiveDecade = computeMostActiveDecade(movies: movies)

        // TIER 1 — Vague
        clues.append(Clue(text: "Appeared in \(totalMovieCount) movies", type: .movieCount, tier: .vague, orderNumber: orderNumber))
        orderNumber += 1

        if let decade = mostActiveDecade {
            clues.append(Clue(text: "Most active in the \(decade)s", type: .decade, tier: .vague, orderNumber: orderNumber))
            orderNumber += 1
        }

        if let topGenre = sortedGenres.first {
            clues.append(Clue(text: "Known for \(topGenre.key)", type: .genre, tier: .vague, orderNumber: orderNumber))
            orderNumber += 1
        }

        if sortedGenres.count >= 2 {
            clues.append(Clue(text: "Also appears in \(sortedGenres[1].key) films", type: .genre, tier: .vague, orderNumber: orderNumber))
            orderNumber += 1
        }

        // TIER 2 — Narrowing
        let shuffledMovies = movies.shuffled()

        if let movie = shuffledMovies.first, let year = movie.year {
            let genre = movie.genres?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? "unknown"
            clues.append(Clue(text: "Appeared in a \(year) \(genre) film", type: .movieYearGenre, tier: .narrowing, orderNumber: orderNumber))
            orderNumber += 1
        }

        if let movie = shuffledMovies.dropFirst().first, let rating = movie.rating {
            clues.append(Clue(text: "Appeared in a film rated \(String(format: "%.1f", rating))/10", type: .rating, tier: .narrowing, orderNumber: orderNumber))
            orderNumber += 1
        }

        // Director clues — prefer directors of high-vote movies
        let sortedDirectors = allDirectors.sorted { ($0.movie.votes ?? 0) > ($1.movie.votes ?? 0) }
        var usedDirectorIds: Set<String> = []
        var directorClueCount = 0

        for entry in sortedDirectors {
            guard directorClueCount < 2 else { break }
            guard !usedDirectorIds.contains(entry.director.nconst) else { continue }
            usedDirectorIds.insert(entry.director.nconst)
            clues.append(Clue(text: "Worked with director \(entry.director.name)", type: .director, tier: .narrowing, orderNumber: orderNumber))
            orderNumber += 1
            directorClueCount += 1
        }

        // TIER 3 — Strong Signals
        let coStarClues: [Clue]
        if difficulty.showCoStarsEarly {
            var coStarTemp: [Clue] = []
            let shuffledCoStars = allCoStars.shuffled()
            for (i, coStar) in shuffledCoStars.prefix(2).enumerated() {
                _ = i
                coStarTemp.append(Clue(text: "Co-starred with \(coStar.name)", type: .coStar, tier: .strongSignal, orderNumber: orderNumber))
                orderNumber += 1
            }
            coStarClues = coStarTemp
        } else {
            // Hard mode: delay co-star clues to tier 4
            coStarClues = []
        }
        clues.append(contentsOf: coStarClues)

        // Combined clues
        if let dirEntry = sortedDirectors.first, let year = dirEntry.movie.year {
            clues.append(Clue(text: "Appeared in a \(year) film directed by \(dirEntry.director.name)", type: .combined, tier: .strongSignal, orderNumber: orderNumber))
            orderNumber += 1
        }

        if let coStar = allCoStars.first {
            let genre = sortedGenres.first?.key ?? "drama"
            clues.append(Clue(text: "Worked with \(coStar.name) in a \(genre) film", type: .combined, tier: .strongSignal, orderNumber: orderNumber))
            orderNumber += 1
        }

        // Hard mode: add co-star clues here in tier 4 instead
        if !difficulty.showCoStarsEarly {
            let shuffledCoStars = allCoStars.shuffled()
            for coStar in shuffledCoStars.prefix(1) {
                clues.append(Clue(text: "Co-starred with \(coStar.name)", type: .coStar, tier: .giveaway, orderNumber: orderNumber))
                orderNumber += 1
            }
        }

        // TIER 4 — Near Giveaway (movie titles)
        // Order by votes ascending so least famous first, most famous last
        let moviesByFame = movies.sorted { ($0.votes ?? 0) < ($1.votes ?? 0) }
        let titleCount = difficulty.movieTitleCluesCount
        let titlesToReveal: [Movie]

        if moviesByFame.count <= titleCount {
            titlesToReveal = moviesByFame
        } else {
            // Pick from different fame levels
            var selected: [Movie] = []
            let step = max(1, moviesByFame.count / titleCount)
            for i in 0..<titleCount {
                let index = min(i * step, moviesByFame.count - 1)
                selected.append(moviesByFame[index])
            }
            // Always make the last one the most famous
            if let mostFamous = moviesByFame.last, selected.last?.tconst != mostFamous.tconst {
                selected[selected.count - 1] = mostFamous
            }
            titlesToReveal = selected
        }

        for movie in titlesToReveal {
            clues.append(Clue(text: "Appeared in \"\(movie.displayTitle)\"", type: .movieTitle, tier: .giveaway, orderNumber: orderNumber))
            orderNumber += 1
        }

        // Trim to max clues for difficulty
        let maxClues = difficulty.maxClues
        if clues.count > maxClues {
            clues = Array(clues.prefix(maxClues))
        }

        // Renumber
        for i in 0..<clues.count {
            clues[i] = Clue(text: clues[i].text, type: clues[i].type, tier: clues[i].tier, orderNumber: i + 1)
        }

        return clues
    }

    // MARK: - Helpers

    private func computeGenreFrequency(movies: [Movie]) -> [String: Int] {
        var freq: [String: Int] = [:]
        for movie in movies {
            guard let genres = movie.genres else { continue }
            for genre in genres.components(separatedBy: ",") {
                let trimmed = genre.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { continue }
                freq[trimmed, default: 0] += 1
            }
        }
        return freq
    }

    private func computeMostActiveDecade(movies: [Movie]) -> Int? {
        var decadeCounts: [Int: Int] = [:]
        for movie in movies {
            guard let year = movie.year else { continue }
            let decade = (year / 10) * 10
            decadeCounts[decade, default: 0] += 1
        }
        return decadeCounts.max(by: { $0.value < $1.value })?.key
    }
}
