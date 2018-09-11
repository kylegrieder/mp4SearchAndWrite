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
    var title: String?
    var genre: String?
    var artwork: NSImage?
    var releaseDate: NSNumber?
    var longDesc: String?
    var storeDesc: String?
    
    let stik = "Movie"
    
    init(withTitle title: String, andYear year: String) {
        
        if let movieId = search.searchForMovieId(withTitle: title, andYear: year),
            let movieDetails = search.getMovieDetails(withId: movieId),
            let posterPath = movieDetails["poster_path"] as? String,
            let moviePoster = search.getMoviePoster(fromPath: posterPath) {
            
            self.artwork = moviePoster
            
            if let movieTitle = movieDetails["title"] as? String,
                let movieReleaseDate = movieDetails["release_date"] as? NSNumber,
                let movieLongDesc = movieDetails["overview"] as? String,
                let movieStoreDesc = movieDetails["tagline"] as? String {
                
                self.title = movieTitle
                self.releaseDate = movieReleaseDate
                self.longDesc = movieLongDesc
                self.storeDesc = movieStoreDesc
            }
            
            if let genreObjects = movieDetails["genres"] as? [[String : Any]] {
                let genres = genreObjects.compactMap { $0["name"] }
                let isActionAdventure = genres.contains {
                    if let genre = $0 as? String {
                        if (genre == "Action" || genre == "Adventure") {
                            return true
                        }
                    }
                    return false
                }
                
                if (isActionAdventure) {
                    self.genre = "Action & Adventure"
                } else {
                    self.genre = genres[0] as? String
                }
            }
        }
    }
}
