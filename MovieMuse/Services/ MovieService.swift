//
//   MovieService.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//

import Combine
import Foundation
import UIKit

protocol MovieService {
    func fetchPopularMovies(pageNo: Int, completion: @escaping (Result<MoviesResponseModel, NetworkError>) -> Void)
    func toggleFavorite(_ movie: Movie, completion: @escaping (Result<Void, Error>) -> Void)
    func searchMovies(with searchText: String, pageNo: Int, completion: @escaping (Result<MoviesResponseModel, NetworkError>) -> Void)
}

enum MovieAPI {
    case movieList(pageNo: Int)
    case searchMovie(name: String, pageNumber: Int)
}

extension MovieAPI: WebServiceProtocol {
    var endPoint: String {
        switch self {
        case let .movieList(pageNo):
            return "/3/movie/popular?api_key=\(apiKey)&page=\(pageNo)"
        case let .searchMovie(name, pageNo):
            return "/3/search/movie?api_key=\(apiKey)&query=\(name)&page=\(pageNo)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .movieList, .searchMovie: return .get
        }
    }
}

open class APIMovieService: MovieService {
    private var cancellables = Set<AnyCancellable>()

    func fetchPopularMovies(pageNo: Int, completion: @escaping (Result<MoviesResponseModel, NetworkError>) -> Void) {
        let cancellable = makeRequest(for: MovieAPI.movieList(pageNo: pageNo), params: nil, completion: completion)
        cancellables.insert(cancellable)
    }

    func searchMovies(with searchText: String, pageNo _: Int, completion: @escaping (Result<MoviesResponseModel, NetworkError>) -> Void) {
        let cancellable = makeRequest(for: MovieAPI.searchMovie(name: searchText, pageNumber: 1), completion: completion)
        cancellables.insert(cancellable)
    }

    func toggleFavorite(_: Movie, completion _: @escaping (Result<Void, Error>) -> Void) {
        // TODO: Implement toggleFavorite method.
    }

    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
}
