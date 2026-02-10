import Foundation

/// Represents a single link in the movie chain - either a movie or an actor
enum ChainLink: Identifiable, Equatable {
    case movie(Movie)
    case actor(Actor)

    var id: String {
        switch self {
        case .movie(let movie):
            return "movie-\(movie.tconst)"
        case .actor(let actor):
            return "actor-\(actor.nconst)"
        }
    }

    var displayName: String {
        switch self {
        case .movie(let movie):
            return movie.title
        case .actor(let actor):
            return actor.name
        }
    }

    var isMovie: Bool {
        if case .movie = self { return true }
        return false
    }

    var isActor: Bool {
        if case .actor = self { return true }
        return false
    }
}

/// Movie data from the SQLite database
struct Movie: Identifiable, Equatable, Hashable {
    let tconst: String
    let title: String
    let year: Int?
    let genres: String?
    let rating: Double?
    let votes: Int?

    var id: String { tconst }

    var displayTitle: String {
        if let year = year {
            return "\(title) (\(year))"
        }
        return title
    }
}

/// Actor data from the SQLite database
struct Actor: Identifiable, Equatable, Hashable {
    let nconst: String
    let name: String
    let knownFor: String?

    var id: String { nconst }
}

/// Director data from the SQLite database
struct Director: Identifiable, Equatable, Hashable {
    let nconst: String
    let name: String

    var id: String { nconst }
}
