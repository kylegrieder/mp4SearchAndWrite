//
//  main.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

let mp4SearchAndWrite = Mp4SearchAndWrite()
let search = Search()

if (CommandLine.argc < 2) {
    //TODO: Handle Static mode
    mp4SearchAndWrite.staticMode()
} else {
    let terms = mp4SearchAndWrite.getSearchTerms()
    
    if let title = terms["title"], let year = terms["year"] {
        search.movie(withTitle: title, andYear: year)
    }
    
}

