#!/usr/bin/env python3
"""
Build Movie Chain SQLite database from IMDb TSV files.

This script processes IMDb data files and creates an optimized SQLite database
for the Movie Chain game containing ALL movies from the IMDb database.

Usage:
    python3 build_movie_database.py [--data-dir PATH] [--output-dir PATH]

The script expects these TSV files in the data directory:
- title.basics.tsv
- title.principals.tsv
- title.ratings.tsv
- name.basics.tsv
"""

import argparse
import csv
import sqlite3
import os
import sys
from pathlib import Path
from typing import Dict, Set, Tuple, Optional
from collections import defaultdict

# Increase CSV field size limit for large fields
csv.field_size_limit(sys.maxsize)


def parse_args():
    parser = argparse.ArgumentParser(description='Build Movie Chain SQLite databases')
    parser.add_argument('--data-dir', type=str,
                        default=str(Path(__file__).parent.parent),
                        help='Directory containing IMDb TSV files')
    parser.add_argument('--output-dir', type=str,
                        default=str(Path(__file__).parent.parent / 'GamesWithFriends' / 'Features' / 'MovieChain' / 'Resources'),
                        help='Directory for output SQLite databases')
    return parser.parse_args()


def load_ratings(data_dir: Path) -> Dict[str, Tuple[float, int]]:
    """Load all movie ratings."""
    print("Loading ratings...")
    ratings = {}
    ratings_file = data_dir / 'title.ratings.tsv'

    with open(ratings_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            try:
                num_votes = int(row['numVotes'])
                ratings[row['tconst']] = (float(row['averageRating']), num_votes)
            except (ValueError, KeyError):
                continue

    print(f"  Found {len(ratings):,} titles with ratings")
    return ratings


def load_all_movies(data_dir: Path) -> Dict[str, dict]:
    """Load ALL movies from title.basics (no filtering by votes)."""
    print("Loading ALL movies...")
    movies = {}
    basics_file = data_dir / 'title.basics.tsv'

    with open(basics_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            tconst = row['tconst']
            # Only include movies (not TV shows, shorts, etc.)
            if row['titleType'] == 'movie':
                # Skip adult content
                if row.get('isAdult', '0') == '1':
                    continue

                year = row.get('startYear', '\\N')
                if year == '\\N':
                    year = None
                else:
                    try:
                        year = int(year)
                    except ValueError:
                        year = None

                movies[tconst] = {
                    'tconst': tconst,
                    'title': row['primaryTitle'],
                    'year': year,
                    'genres': row.get('genres', '').replace('\\N', '')
                }

    print(f"  Loaded {len(movies):,} movies")
    return movies


def load_actors(data_dir: Path) -> Dict[str, dict]:
    """Load actor/actress information."""
    print("Loading actors...")
    actors = {}
    names_file = data_dir / 'name.basics.tsv'

    with open(names_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            professions = row.get('primaryProfession', '')
            # Include people who are actors or actresses
            if 'actor' in professions or 'actress' in professions:
                known_for = row.get('knownForTitles', '').replace('\\N', '')
                actors[row['nconst']] = {
                    'nconst': row['nconst'],
                    'name': row['primaryName'],
                    'known_for': known_for.split(',') if known_for else []
                }

    print(f"  Loaded {len(actors):,} actors/actresses")
    return actors


def load_movie_actor_links(data_dir: Path, valid_movies: Set[str]) -> Dict[str, Set[str]]:
    """Load movie-actor links from title.principals, filtering to valid movies."""
    print("Loading movie-actor links...")
    # movie_id -> set of actor_ids
    links = defaultdict(set)
    principals_file = data_dir / 'title.principals.tsv'

    with open(principals_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            tconst = row['tconst']
            category = row.get('category', '')

            # Only include actors/actresses in movies we care about
            if tconst in valid_movies and category in ('actor', 'actress'):
                links[tconst].add(row['nconst'])

    total_links = sum(len(v) for v in links.values())
    print(f"  Loaded {total_links:,} movie-actor links for {len(links):,} movies")
    return links


def create_database(output_path: Path, movies: Dict[str, dict],
                   actors: Dict[str, dict], links: Dict[str, Set[str]],
                   ratings: Dict[str, Tuple[float, int]]):
    """Create the SQLite database with all tables and indexes."""
    print(f"Creating database: {output_path}")

    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Remove existing database
    if output_path.exists():
        output_path.unlink()

    conn = sqlite3.connect(str(output_path))
    cursor = conn.cursor()

    # Create tables
    cursor.executescript('''
        -- Movies table
        CREATE TABLE movies (
            tconst TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            year INTEGER,
            genres TEXT,
            rating REAL,
            votes INTEGER
        );

        -- Actors table
        CREATE TABLE actors (
            nconst TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            known_for TEXT
        );

        -- Movie-Actor links (the critical relationship table)
        CREATE TABLE movie_actors (
            tconst TEXT NOT NULL,
            nconst TEXT NOT NULL,
            PRIMARY KEY (tconst, nconst),
            FOREIGN KEY (tconst) REFERENCES movies(tconst),
            FOREIGN KEY (nconst) REFERENCES actors(nconst)
        );

        -- Full-text search for movies
        CREATE VIRTUAL TABLE movies_fts USING fts5(
            title,
            content='movies',
            content_rowid='rowid'
        );

        -- Full-text search for actors
        CREATE VIRTUAL TABLE actors_fts USING fts5(
            name,
            content='actors',
            content_rowid='rowid'
        );
    ''')

    # Insert movies
    print("  Inserting movies...")
    movie_rows = []
    for tconst, movie in movies.items():
        rating_info = ratings.get(tconst, (None, None))
        movie_rows.append((
            tconst,
            movie['title'],
            movie['year'],
            movie['genres'],
            rating_info[0],
            rating_info[1]
        ))

    cursor.executemany(
        'INSERT INTO movies (tconst, title, year, genres, rating, votes) VALUES (?, ?, ?, ?, ?, ?)',
        movie_rows
    )

    # Build set of actors we actually need (those linked to our movies)
    needed_actors = set()
    for movie_actors in links.values():
        needed_actors.update(movie_actors)

    # Insert only actors that appear in our movies
    print("  Inserting actors...")
    actor_rows = []
    for nconst in needed_actors:
        if nconst in actors:
            actor = actors[nconst]
            actor_rows.append((
                nconst,
                actor['name'],
                ','.join(actor['known_for']) if actor['known_for'] else None
            ))

    cursor.executemany(
        'INSERT INTO actors (nconst, name, known_for) VALUES (?, ?, ?)',
        actor_rows
    )
    print(f"  Inserted {len(actor_rows):,} actors")

    # Insert movie-actor links
    print("  Inserting movie-actor links...")
    link_rows = []
    for tconst, actor_ids in links.items():
        for nconst in actor_ids:
            if nconst in actors:  # Only link to actors we have
                link_rows.append((tconst, nconst))

    cursor.executemany(
        'INSERT INTO movie_actors (tconst, nconst) VALUES (?, ?)',
        link_rows
    )
    print(f"  Inserted {len(link_rows):,} links")

    # Populate FTS indexes
    print("  Building full-text search indexes...")
    cursor.execute('''
        INSERT INTO movies_fts(rowid, title)
        SELECT rowid, title FROM movies
    ''')
    cursor.execute('''
        INSERT INTO actors_fts(rowid, name)
        SELECT rowid, name FROM actors
    ''')

    # Create additional indexes for fast lookups
    print("  Creating indexes...")
    cursor.executescript('''
        -- Index for finding actors in a movie
        CREATE INDEX idx_movie_actors_movie ON movie_actors(tconst);

        -- Index for finding movies with an actor
        CREATE INDEX idx_movie_actors_actor ON movie_actors(nconst);

        -- Index for sorting movies by popularity
        CREATE INDEX idx_movies_votes ON movies(votes DESC);

        -- Index for year filtering
        CREATE INDEX idx_movies_year ON movies(year);
    ''')

    conn.commit()
    conn.close()

    # Report file size
    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f"  Database size: {size_mb:.1f} MB")


def verify_database(db_path: Path):
    """Run verification queries on the database."""
    print(f"\nVerifying database: {db_path.name}")
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()

    # Count records
    cursor.execute('SELECT COUNT(*) FROM movies')
    movie_count = cursor.fetchone()[0]

    cursor.execute('SELECT COUNT(*) FROM actors')
    actor_count = cursor.fetchone()[0]

    cursor.execute('SELECT COUNT(*) FROM movie_actors')
    link_count = cursor.fetchone()[0]

    print(f"  Movies: {movie_count:,}")
    print(f"  Actors: {actor_count:,}")
    print(f"  Links: {link_count:,}")

    # Test a sample query - search for "Matrix"
    print("\n  Sample search for 'Matrix':")
    cursor.execute('''
        SELECT m.title, m.year, m.votes
        FROM movies m
        JOIN movies_fts fts ON m.rowid = fts.rowid
        WHERE movies_fts MATCH 'Matrix*'
        ORDER BY m.votes DESC
        LIMIT 5
    ''')
    for row in cursor.fetchall():
        print(f"    {row[0]} ({row[1]}) - {row[2]:,} votes")

    # Test actor search
    print("\n  Sample search for 'Keanu':")
    cursor.execute('''
        SELECT a.name
        FROM actors a
        JOIN actors_fts fts ON a.rowid = fts.rowid
        WHERE actors_fts MATCH 'Keanu*'
        LIMIT 5
    ''')
    for row in cursor.fetchall():
        print(f"    {row[0]}")

    # Test movie-actor link
    print("\n  Sample: Actors in 'The Matrix' (1999):")
    cursor.execute('''
        SELECT a.name
        FROM actors a
        JOIN movie_actors ma ON a.nconst = ma.nconst
        JOIN movies m ON ma.tconst = m.tconst
        WHERE m.title = 'The Matrix' AND m.year = 1999
        LIMIT 10
    ''')
    for row in cursor.fetchall():
        print(f"    {row[0]}")

    conn.close()


def main():
    args = parse_args()
    data_dir = Path(args.data_dir)
    output_dir = Path(args.output_dir)

    print("=" * 60)
    print("Movie Chain Database Builder - COMPLETE DATABASE")
    print("=" * 60)
    print(f"Data directory: {data_dir}")
    print(f"Output directory: {output_dir}")
    print()

    # Verify input files exist
    required_files = ['title.basics.tsv', 'title.principals.tsv',
                      'title.ratings.tsv', 'name.basics.tsv']
    for filename in required_files:
        if not (data_dir / filename).exists():
            print(f"ERROR: Missing required file: {filename}")
            sys.exit(1)

    # Load all actors first (we'll filter later)
    actors = load_actors(data_dir)

    # Load all ratings (for display purposes, not filtering)
    ratings = load_ratings(data_dir)

    # Build COMPLETE database with ALL movies
    print("\n" + "=" * 60)
    print("Building COMPLETE database (ALL movies)")
    print("=" * 60)

    all_movies = load_all_movies(data_dir)
    all_links = load_movie_actor_links(data_dir, set(all_movies.keys()))

    db_path = output_dir / 'moviechain_core.sqlite'
    create_database(db_path, all_movies, actors, all_links, ratings)
    verify_database(db_path)

    print("\n" + "=" * 60)
    print("BUILD COMPLETE!")
    print("=" * 60)
    print(f"\nDatabase created: {db_path}")
    print(f"This database contains ALL {len(all_movies):,} movies from IMDb!")


if __name__ == '__main__':
    main()
