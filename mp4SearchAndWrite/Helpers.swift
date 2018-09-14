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
        let path = "/usr/local/bin/mp4Write.sh"
        
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        
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
