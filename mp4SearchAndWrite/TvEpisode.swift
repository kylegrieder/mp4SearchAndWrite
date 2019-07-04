//
//  TvEpisode.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 6/1/19.
//  Copyright © 2019 Kyle Grieder. All rights reserved.
//

import Foundation
import Cocoa

let search = Search()

class TvEpisode {
    var show: String?
    var genre: String?
    var artworkData: Data?
    var airDate: String?
    var longDesc: String?
    var storeDesc: String?
    
    let stik = "TV Show"
    
    init(withShow show: String, andSeason season: String, andEpisode episode: String) {
        
        if let showId = search.searchForTvShowId(withShow: show) {
            
        }
        
    }
    
}
