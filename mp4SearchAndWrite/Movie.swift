//
//  Movie.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation
import Cocoa

let search = Search()

class Movie {
    var title: String?   // implemented
    var genre: String? // implemented
    var artworkData: Data? // implemented
    var releaseDate: String? // implemented
    var longDesc: String? // implemented
    var storeDesc: String? // implemented
    var mpaaCertification: String? // implemented    
    
    let stik = "Movie" // implemented
    
    init(withTitle title: String, andYear year: String) {
        
        if let movieId = search.searchForMovieId(withTitle: title, andYear: year),
            let movieDetails = search.getMovieDetails(withId: movieId),
            let posterPath = movieDetails["poster_path"] as? String,
            // Artwork Logic
            let moviePosterData = search.getMoviePosterData(fromPath: posterPath) {
            self.artworkData = moviePosterData
            // Details logic
            consoleIO.writeMessage("Setting movie details variables...")
            if let movieReleaseDate = movieDetails["release_date"] as? String,
                let movieLongDesc = movieDetails["overview"] as? String,
                let movieStoreDesc = movieDetails["tagline"] as? String {
                consoleIO.writeMessage(" Movie details variables were set successfully.\n  Attaching to Movie Object.")
                self.title = title
                self.releaseDate = movieReleaseDate
                self.longDesc = movieLongDesc
                self.storeDesc = movieStoreDesc
                consoleIO.writeMessage("   Variables were successfully attached.")
            } else {
                consoleIO.writeMessage(" Unable to set details variables.")
            }
            // Genre logic
            if let genreObjects = movieDetails["genres"] as? [[String : Any]] {
                let genres = genreObjects.compactMap { $0["name"] }
                
                let isActionAdventure = genres.contains {
                    if let genre = $0 as? String {
                        return (genre == "Action" || genre == "Adventure") ? true : false
                    }
                    return false
                }

                let isFamily = genres.contains {
                    if let genre = $0 as? String {
                        return genre == "Animation" || genre == "Family" ? true : false
                    }
                    return false
                }

                if (isFamily) {
                    self.genre = "Family"
                } else if (isActionAdventure) {
                    self.genre = "Action & Adventure"
                } else {
                    self.genre = genres[0] as? String
                }
            }
            // MPAA Certification logic
            if let releaseDateObject = movieDetails["release_dates"] as? [String : Any],
                let releaseResultsArr = releaseDateObject["results"] as? [Any] {
                let _ = releaseResultsArr.map {(result) in
                    if let regionObj = result as? [String : Any],
                        let iso31661 = regionObj["iso_3166_1"] as? String,
                        let regionReleaseDatesObj = regionObj["release_dates"] as? [[String : Any]],
                        let mpaaCertification = regionReleaseDatesObj[0]["certification"] as? String {
                        if (iso31661 == "US") {
                            self.mpaaCertification = mpaaCertification
                        }
                    }
                }
            }
            //
        }
    }
}
