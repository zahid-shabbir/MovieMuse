//
//  Movie.swift .swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//

import Foundation
import UIKit

// MARK: - MoviesResponseModel

struct MoviesResponseModel: Codable {
    let movies: [Movie]?
    let totalPages, totalResults, page: Int?

    enum CodingKeys: String, CodingKey {
        case movies = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case page
    }
}

// MARK: - Result

struct Movie: Codable {
    let id: Int?
    let title, overview, posterPath, releaseDate: String?
    let voteAverage: Double?
    var isFavorited: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case overview, title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}
