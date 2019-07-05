//
//  TvEpisode.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 6/1/19.
//  Copyright © 2019 Kyle Grieder. All rights reserved.
//

import Foundation
import Cocoa

class TvEpisode {
    var title: String?
    var genre: String?
    var artworkData: Data?
    var airDate: String?
    var longDesc: String?
    var storeDesc: String?
    var episodeNumber: Int?
    var seasonNumber: Int?

    let stik = "TV Show"

    init(withTitle title: String, season: String, episode: String) {

//        if let showId = search.searchForTvShowId(withShow: show) {
//
//        }
        
        if let showDetails = search.searchForTvShowDetails(withTitle: title),
            let tvEpisodeDetails = search.getTvEpisodeDetails(withId: String(showDetails["id"]), season: season, episode: episode),
            let posterPath = showDetails["poster_path"] as? String,
            // Artwork Logic
            let showPosterData = search.getPosterData(fromPath: posterPath) {
            self.artworkData = showPosterData
            // Details logic
            consoleIO.writeMessage("Setting show details...")
            if let tvEpisodeTitle = tvEpisodeDetails["name"] as? String,
                let tvEpisodeAirDate = tvEpisodeDetails["air_date"] as? String,
                let tvEpisodeLongDesc = tvEpisodeDetails["overview"] as? String,
                let tvEpisodeStoreDesc = tvEpisodeDetails["overview"] as? String,
                let tvEpisodeNumber = tvEpisodeDetails["episode_number"] as? Int,
                let tvEpisodeSeasonNumber = tvEpisodeDetails["season_number"] as? Int {
                    self.title = tvEpisodeTitle
                    self.releaseDate = tvEpisodeAirDate
                    self.longDesc = tvEpisodeLongDesc
                    self.storeDesc = tvEpisodeStoreDesc
                    self.episodeNumber = tvEpisodeNumber
                    self.seasonNumber = tvEpisodeSeasonNumber
            } else {
                consoleIO.writeMessage("Unable to set details.")
            }
            // Genre logic
            if let genreObjects = showDetails["genres"] as? [[String: Any]] {
                let genres = genreObjects.compactMap {
                    $0["name"] as? String
                }
                
                self.genre = helpers.processGenres(genres: genres)
            }
        }
    }

}
