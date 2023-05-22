//
//  MovieDetailViewModel.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//

import Foundation

class MovieDetailViewModel {
    private let movieService: MovieService
    private let router: MovieListRouter

    var movie: Movie

    init(movie: Movie, movieService: MovieService, router: MovieListRouter) {
        self.movie = movie
        self.movieService = movieService
        self.router = router
    }

    func toggleFavorite() {
        movieService.toggleFavorite(movie) { [weak self] result in
            switch result {
            case .success:
                // Handle successful toggling of favorite
                break
            case let .failure(error):
                // Handle error
                self?.handleError(error)
            }
        }
    }

    private func handleError(_: Error) {
        // Handle error logic
    }
}
