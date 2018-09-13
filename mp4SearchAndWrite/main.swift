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
            
            let path = "/bin/sh"
            
            let task = Process()
            task.launchPath = path
            task.arguments = ["--login", "cd", "/Users/kylegrieder/Downloads", "ls"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            
            task.launch()
            
            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            let outputString = String(data: outputData, encoding: String.Encoding.utf8)
            
            consoleIO.writeMessage(outputString!)
        }
        
    }
}

main()
