//
//  ConsoleIO.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

class ConsoleIO {
    
    enum OutputType {
        case error
        case help
        case standard
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\(message) \r", terminator: "")
        case .error:
            fputs("Error: \(message)\n", stderr)
        case .help:
            print("\(message)")
        }
    }
    
    func printHelp() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("You can include the title and year as their own parameters or, if the file\'s name is properly formatted, \(executableName) will parse it for you.", to:.help)
        writeMessage("The file format should be \"{Full Title} ({Release Year}).mp4\". See below for example.", to:.help)
        
        writeMessage("Parameters:", to:.help)
        writeMessage("-p: Path to .mp4 File (required)", to:.help)
        writeMessage("-T: Type (i.e. - \"Movie\" or \"TV\" (required)", to:.help)
        writeMessage("-t: Movie Title", to:.help)
        writeMessage("-y: Movie year", to:.help)
        
        writeMessage("Examples:", to:.help)
        writeMessage("\(executableName) -t \"The Avengers\" -y \"2012\" -T \"Movie\" -p \"/Users/kyle/Movies/The Avengers.mp4\"", to:.help)
        writeMessage("\(executableName) -p \"/Volumes/Media/Movies/The Avengers (2012).mp4\" -T \"Movie\"", to:.help)
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("******** mp4SearchAndWrite ******** \n", to:.help)
        writeMessage("\(executableName) - search for a movie using the Title and Year, \ngrab the meta data from TheMovieDB.org and write it to an .mp4 file. \nCurrently the application isn't interactive, meaning it just grabs \nthe first result from the response. \n", to:.help)
        writeMessage("This is why including the year is so important. \n \nUse \'-h\' for usage and examples.", to:.help)
    }
}
