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
        
        //            let outputHandle = pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        task.launch()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: String.Encoding.utf8)
        
        consoleIO.writeMessage(outputString!)
    }
}
