//
//  MovieDetailViewController.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 21/05/2023.
//

import UIKit
class MovieDetailViewController: UIViewController, Injectable {
    // Outlets and UI components
    @IBOutlet var movieContainerView: UIView!
    @IBOutlet var movieNameLabel: UILabel!
    @IBOutlet var movieDetailLabel: UILabel!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    
    var movie: Movie!
    var viewModel: MovieDetailViewModel!
    
    struct Dependency {
        let movie: Movie
        let service: MovieService
        let router: MovieListRouter
    }
    
    func inject(dependency: Dependency) {
        movie = dependency.movie
        viewModel = MovieDetailViewModel(movie: dependency.movie, movieService: dependency.service, router: dependency.router)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // Resize or reset your layout here
            self.movieContainerView.layoutIfNeeded() // force any pending layout updates to occur immediately
            self.movieContainerView.addGradient(colors: [#colorLiteral(red: 0.07800000161, green: 0.08200000226, blue: 0.125, alpha: 1), #colorLiteral(red: 0.125, green: 0.1289999932, blue: 0.175999999, alpha: 1)])
        }, completion: nil)
    }
    
    private func updateView() {
        movieContainerView.addGradient(colors: [#colorLiteral(red: 0.07800000161, green: 0.08200000226, blue: 0.125, alpha: 1), #colorLiteral(red: 0.125, green: 0.1289999932, blue: 0.175999999, alpha: 1)])
        movieContainerView.applyCornerRadius(5)
        
        movieNameLabel.text = viewModel.movie.title
        movieDetailLabel.text = viewModel.movie.overview
        ratingLabel.text = "★ \(viewModel.movie.voteAverage?.description ?? "")"
        let urlString = imageBaseUrl + (movie.posterPath ?? "")
        posterImageView.downloads(from: urlString)
    }
}
