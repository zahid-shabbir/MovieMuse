//
//  MovieListCell.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 18/05/2023.
//

import UIKit

class MovieListCell: UICollectionViewCell {
    @IBOutlet var movieNameLabel: UILabel!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    var toggleFavorite: (() -> Void)?

    func configure(with movie: Movie, isSearching: Bool, toggleFavorite: @escaping () -> Void) {
        layer.cornerRadius = 5

        movieNameLabel.text = movie.title
        releaseDateLabel.text = movie.releaseDate
        movieNameLabel.textAlignment = .center
        releaseDateLabel.textAlignment = .center
        let urlString = imageBaseUrl + (movie.posterPath ?? "")
        posterImageView.downloads(from: urlString)
        movieNameLabel.backgroundColor = #colorLiteral(red: 0.09799999744, green: 0.1019999981, blue: 0.1449999958, alpha: 1)
        movieNameLabel.font = isSearching ? UIFont.preferredFont(forTextStyle: .title3) : UIFont.preferredFont(forTextStyle: .title1)
           
            
        let heartImage = movie.isFavorited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        heartButton.setImage(heartImage, for: .normal)
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)

        self.toggleFavorite = toggleFavorite
        
    }

    @IBAction func heartButtonTapped(_: UIButton) {
        toggleFavorite?()
    }
}
