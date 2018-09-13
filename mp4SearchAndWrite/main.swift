//
//  main.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

let mp4SearchAndWrite = Mp4SearchAndWrite()

func main() {
    if (CommandLine.argc < 2) {
        //TODO: Handle Static mode
        mp4SearchAndWrite.staticMode()
    } else {
        let terms = mp4SearchAndWrite.getSearchTerms()
        
        if let title = terms["title"], let year = terms["year"] {
            let movie = Movie(withTitle: title, andYear: year)
            
            // todo handle movie.artwork
            
            if let title = movie.title,
                let genre = movie.genre,
                let releaseDate = movie.releaseDate,
                let longDesc = movie.longDesc,
                let storeDesc = movie.storeDesc,
                let mpaaCert = movie.mpaaCertification {
                
                let arguments = [title, genre, releaseDate, longDesc, storeDesc, mpaaCert, movie.stik]
                mp4WriteScript(withArguments: arguments)
            }
        }
    }
}

func mp4WriteScript(withArguments arguments: [String]) {
    let path = "/usr/local/bin/mp4Write.sh"
    
    let task = Process()
    task.launchPath = path
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    //            let outputHandle = pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    
    task.launch()
    
    let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
    let outputString = String(data: outputData, encoding: String.Encoding.utf8)
    
    consoleIO.writeMessage(outputString!)
}

main()
