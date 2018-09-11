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
    var artwork: NSImage?
    var year: NSNumber?
    var longDesc: String?
    var storeDesc: String?
    
    let stik = "Movie"
    
    init(withYear year: NSNumber) {
        self.year = year
    }
}
