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
    
    public func mp4WriteScript(withArguments arguments: [String]) {
        
        let script = "/usr/local/bin/atomicparsley \(arguments[0]) -W --artwork \(arguments[1]) --title \(arguments[2]) --genre \(arguments[3]) --year \(arguments[4]) --longdesc \(arguments[5]) --storedesc \(arguments[6]) --description \(arguments[6]) --contentRating \(arguments[7]) --stik \(arguments[8]) && rm -rf  \(arguments[1])"

        
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
                consoleIO.writeMessage("Error decoding data: \(outputHandle.availableData)")
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
}
