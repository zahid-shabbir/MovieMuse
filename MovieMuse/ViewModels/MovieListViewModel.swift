//
//  MovieListViewModel.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//

import Combine
import Foundation

class MovieListViewModel {
    private let movieService: MovieService
    private let router: MovieListRouter
    var currentPage = 0
    var totalPageCount = 0
    private var isLoadingMoreMovies = false
    var currentPageInSearch = 0
    var totalPageCountInSearch = 0
    // private var debounceTimer: Timer?
    @Published var movies: [Movie] = []
    @Published var error: Error?
    var originalMovies: [Movie] = []
    init(movieService: MovieService, router: MovieListRouter) {
        self.movieService = movieService
        self.router = router
    }
    
    func fetchPopularMovies() {
        guard !isLoadingMoreMovies, currentPage <= totalPageCount else {
            return
        }
        guard ReachabilityManager.shared.isNetworkAvailable else {
            // returning favourite from coredata
            movies = Favorite.getFavorites()
            movies.indices.forEach { index in
                self.movies[index].isFavorited = true
            }
            currentPage = 0
            totalPageCount = 0
            return
        }
        
        isLoadingMoreMovies = true
        movieService.fetchPopularMovies(pageNo: currentPage + 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.movies.append(contentsOf: response.movies ?? [])
                self.currentPage = response.page ?? 1
                self.totalPageCount = response.totalPages ?? 0
            case let .failure(failure):
                self.error = failure
            }
            self.isLoadingMoreMovies = false
        }
    }
    
    func searchMovies(with searchText: String) {
        if searchText.isEmpty {
            // Restore original state if search text is empty
            movies = originalMovies
            originalMovies.removeAll()
        } else {
            // Call the search API service
            movieService.searchMovies(with: searchText, pageNo: currentPageInSearch + 1) { [weak self] result in
                switch result {
                case let .success(response):
                    // Update the movies array with the search results
                    self?.movies = response.movies ?? []
                    self?.currentPageInSearch = response.page ?? 1
                    self?.totalPageCountInSearch = response.totalPages ?? 0
                case let .failure(error):
                    // Handle the error case
                    print("Search API error: \(error)")
                    // TODO: Implement Search API error.
                }
            }
        }
    }
    
    func toggleFavorite(at index: Int) -> Bool {
        movies[index].isFavorited.toggle()
        let isFavorite = movies[index].isFavorited
        if isFavorite {
            Favorite.saveFavorite(movie: movies[index])
        } else {
            Favorite.deleteFavorite(movie: movies[index])
        }
        
        return isFavorite
    }
    
    func showMovieDetail(for movie: Movie) {
        router.showMovieDetail(for: movie, movieService: movieService)
    }
}
