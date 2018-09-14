//
//  main.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

let mp4SearchAndWrite = Mp4SearchAndWrite()
let helpers = Helpers()

func main() {
    if (CommandLine.argc < 2) {
        //TODO: Handle Static mode
        mp4SearchAndWrite.staticMode()
    } else {
        let terms = mp4SearchAndWrite.getTerms()
        
        if let title = terms["title"], let year = terms["year"], let filePath = terms["path"] {
            let movie = Movie(withTitle: title, andYear: year)
            
            // TODO: handle movie.artworkData
            
            if let title = movie.title,
                let genre = movie.genre,
                let releaseDate = movie.releaseDate,
                let longDesc = movie.longDesc,
                let storeDesc = movie.storeDesc,
                let mpaaCert = movie.mpaaCertification {
                
                let arguments = [filePath, title, genre, releaseDate, longDesc, storeDesc, mpaaCert, movie.stik]
                helpers.mp4WriteScript(withArguments: arguments)
            }
        }
    }
}

main()
