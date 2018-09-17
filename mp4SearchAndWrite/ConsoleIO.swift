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
        case standard
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\(message)")
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
    
    func printHelp() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("You can include the title and year as their own parameters or, if the file\'s name is properly formatted, \(executableName) will parse it for you.")
        writeMessage("The file format should be \"{Full Title} ({Release Year}).mp4\". See below for example.")
        
        writeMessage("Parameters:")
        writeMessage("-p: Path to .mp4 File (required)")
        writeMessage("-T: Type (i.e. - \"Movie\" or \"TV\" (required)")
        writeMessage("-t: Movie Title")
        writeMessage("-y: Movie year")
        
        writeMessage("Examples:")
        writeMessage("\(executableName) -t \"The Avengers\" -y \"2012\" -T \"Movie\" -p \"/Users/kyle/Movies/The Avengers.mp4\"")
        writeMessage("\(executableName) -p \"/Volumes/Media/Movies/The Avengers (2012).mp4\" -T \"Movie\"")
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("******** mp4SearchAndWrite ******** \n")
        writeMessage("\(executableName) - search for a movie using the Title and Year, \ngrab the meta data from TheMovieDB.org and write it to an .mp4 file. \nCurrently the application isn't interactive, meaning it just grabs \nthe first result from the response. \n")
        
        writeMessage("This is why including the year is so important. \n \nUse \'-h\' for usage and examples.")
    }
}
