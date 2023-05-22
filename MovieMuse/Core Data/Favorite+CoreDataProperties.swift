//
//  Favorite+CoreDataProperties.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 22/05/2023.
//
//

import CoreData
import Foundation

public extension Favorite {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Favorite> {
        NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged var id: Int32
    @NSManaged var overview: String?
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: String?
    @NSManaged var title: String?
    @NSManaged var voteAverage: Double
}

extension Favorite: Identifiable {}
