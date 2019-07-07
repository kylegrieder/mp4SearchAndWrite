//
//  Helpers.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/13/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

class Helpers {
    
    init(){
        
    }
    
    public func mp4WriteScript(withArguments arguments: [String], type: String) {
        
        var script: String
        
        if (type == "tv show") {
            let episodeNumber = String(arguments[9]).count == 1 ? "0\(arguments[9])" : "\(arguments[9])"
            let seasonNumber = String(arguments[10]).count == 1 ? "0\(arguments[10])" : "\(arguments[10])"
            
            script = "/usr/local/bin/atomicparsley \"\(arguments[0])\" -W --artwork \"\(arguments[1])\" --title \"\(arguments[2])\" --genre \"\(arguments[3])\" --year \"\(arguments[4])\" --longdesc \"\(arguments[5])\" --storedesc \"\(arguments[6])\" --description \"\(arguments[6])\" --stik \"\(arguments[7])\" --TVShowName \"\(arguments[8])\" --TVEpisodeNum \"\(episodeNumber)\" --TVSeasonNum \"\(seasonNumber)\" --TVEpisode \"S\(seasonNumber)E\(episodeNumber)\" && rm -rf  \"\(arguments[1])\""
        } else if (type == "movie") {
            script = "/usr/local/bin/atomicparsley \"\(arguments[0])\" -W --artwork \"\(arguments[1])\" --title \"\(arguments[2])\" --genre \"\(arguments[3])\" --year \"\(arguments[4])\" --longdesc \"\(arguments[5])\" --storedesc \"\(arguments[6])\" --description \"\(arguments[6])\" --contentRating \"\(arguments[7])\" --stik \"\(arguments[8])\" && rm -rf  \"\(arguments[1])\""
        } else {
            script = ""
            consoleIO.writeMessage("Failed to set script type")
            exit(1)
        }

        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.readabilityHandler = { outputHandle in
            if let dataString = String(data: outputHandle.availableData, encoding: String.Encoding.utf8) {
                print("\(dataString) \r", terminator: "")
                fflush(stdout)
                sleep(UInt32(0.01))
            } else {
                consoleIO.writeMessage("Error decoding data: \(outputHandle.availableData)", to: .error)
            }
        }
        
        var dataReady : NSObjectProtocol!
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: outputHandle, queue: nil, using: { (notification) in
            consoleIO.writeMessage("Task Terminated!")
            NotificationCenter.default.removeObserver(dataReady)
        })
        
        task.launch()
        task.waitUntilExit()
        
    }
    
    public func savePosterImage(fromData data:Data?, toPath path: String) {
        let _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    public func processGenres(genres: [String]) -> String {
        var genre: String
        
        let isActionAdventure = genres.contains {
            return ($0 == "Action" || $0 == "Adventure")
        }
        
        let isFamily = genres.contains {
            return ($0 == "Animation" || $0 == "Family")
        }
        
        if (isFamily) {
            genre = "Family"
        } else if (isActionAdventure) {
            genre = "Action & Adventure"
        } else {
            genre = genres[0]
        }
        
        return genre
    }
}
