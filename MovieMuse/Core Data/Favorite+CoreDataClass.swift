//
//  Favorite+CoreDataClass.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 22/05/2023.
//
//

import CoreData
import Foundation

@objc(Favorite)
public class Favorite: NSManagedObject {
    static func saveFavorite(movie: Movie) {
        let newFavoriteMovie = Favorite(context: CoreDataManager.shared.context)
        newFavoriteMovie.id = Int32(movie.id ?? 0)
        newFavoriteMovie.title = movie.title
        newFavoriteMovie.overview = movie.overview
        newFavoriteMovie.posterPath = movie.posterPath
        newFavoriteMovie.releaseDate = movie.releaseDate
    }

    static func getFavorites() -> [Movie] {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()

        do {
            let favorites = try CoreDataManager.shared.context.fetch(fetchRequest)

            return favorites.map { Movie(id: Int($0.id), title: $0.title, overview: $0.overview, posterPath: $0.posterPath, releaseDate: $0.releaseDate, voteAverage: $0.voteAverage) }
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }

    static func deleteFavorite(movie: Movie) {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", movie.id ?? 0)

        do {
            let favorites = try CoreDataManager.shared.context.fetch(fetchRequest)
            for favorite in favorites {
                CoreDataManager.shared.context.delete(favorite)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to delete favorite: \(error)")
        }
    }
}
