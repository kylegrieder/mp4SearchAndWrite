//
//  Movie.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation
import Cocoa

class Movie {
    var title: String?
    var genre: String?
    var artworkData: Data?
    var releaseDate: String?
    var longDesc: String?
    var storeDesc: String?
    var mpaaCertification: String?

    let stik = "Movie"

    init(withTitle title: String, andYear year: String) {

        if let movieId = search.searchForMovieId(withTitle: title, andYear: year),
           let movieDetails = search.getMovieDetails(withId: movieId),
           let posterPath = movieDetails["poster_path"] as? String,
           // Artwork Logic
           let moviePosterData = search.getPosterData(fromPath: posterPath) {
            self.artworkData = moviePosterData
            // Details logic
            consoleIO.writeMessage("Setting movie details...")
            if let movieTitle = movieDetails["title"] as? String,
               let movieReleaseDate = movieDetails["release_date"] as? String,
               let movieLongDesc = movieDetails["overview"] as? String,
               let movieStoreDesc = movieDetails["tagline"] as? String {
                self.title = movieTitle
                self.releaseDate = movieReleaseDate
                self.longDesc = movieLongDesc
                self.storeDesc = movieStoreDesc
            } else {
                consoleIO.writeMessage("Unable to set details.")
            }
            // Genre logic
            if let genreObjects = movieDetails["genres"] as? [[String: Any]] {
                let genres = genreObjects.compactMap {
                    $0["name"] as? String
                }
                
                self.genre = helpers.processGenres(genres: genres)
            }
            // MPAA Certification logic
            if let releaseDateObject = movieDetails["release_dates"] as? [String: Any],
               let releaseResultsArr = releaseDateObject["results"] as? [Any] {
                let _ = releaseResultsArr.map { (result) in
                    if let regionObj = result as? [String: Any],
                       let iso31661 = regionObj["iso_3166_1"] as? String,
                       let regionReleaseDatesObj = regionObj["release_dates"] as? [[String: Any]],
                       let mpaaCertification = regionReleaseDatesObj[0]["certification"] as? String {
                        if (iso31661 == "US") {
                            self.mpaaCertification = mpaaCertification
                        }
                    }
                }
            }
        }
    }
}
