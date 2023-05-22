//
//  MovieListRouter.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 21/05/2023.
//

import Foundation

import UIKit

class MovieListRouter {
    weak var viewController: UIViewController?

    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    func showMovieDetail(for movie: Movie, movieService: MovieService) {
        let router = MovieListRouter(viewController: viewController!)

        let dependency = MovieDetailViewController.Dependency(movie: movie, service: movieService, router: router)
        let movieDetailViewController = MovieDetailViewController.instantiate(with: dependency)

        viewController?.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}
