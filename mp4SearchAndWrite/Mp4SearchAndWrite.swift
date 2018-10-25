//
//  Mp4SearchAndWrite.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

enum OptionType: String {
    case title = "t"
    case year = "y"
    case help = "h"
    case path = "p"
    case type = "T"
    case unknown = ""
    
    init(value: String) {
        switch value {
        case "t": self = .title
        case "title": self = .title
        case "y": self = .year
        case "year": self = .year
        case "h": self = .help
        case "help": self = .help
        case "p": self = .path
        case "path": self = .path
        case "T": self = .type
        case "Type": self = .type
        default: self = .unknown
        }
    }
}

class Mp4SearchAndWrite {
    
    let consoleIO = ConsoleIO()
    
    func staticMode() {
        consoleIO.printUsage()
    }
    
    func helpMode() {
        consoleIO.printHelp()
    }
    
    func getOption(_ option: String) -> (option: OptionType, value: String) {
        let arguments = CommandLine.arguments
        
        if (option == "h" || option == "help") {
            return (OptionType(value:option), option)
        } else if let index = arguments.index(of: "-" + option) {
            let value = arguments[index + 1]
            return (OptionType(value: option), value)
        } else if let index = arguments.index(of: "--" + option) {
            let value = arguments[index + 1]
            return (OptionType(value: option), value)
        } else {
            return (OptionType(value:""), "")
        }
    }
    
    func getTerms() -> [String : Any] {
        var terms: Dictionary = ["title": "", "year": "", "path": "", "type": "movie", "help": false] as [String : Any]
        
        for argument in CommandLine.arguments {
            let (option, value) = getOption(String(argument.suffix(from: argument.index(argument.startIndex, offsetBy: 1))))
            
            switch option {
            case .title: terms["title"] = value
            case .year: terms["year"] = value
            case .path: terms["path"] = value
            case .type: terms["type"] = value.lowercased()
            case .help: terms["help"] = true
            default: break
            }
        }
        return terms
    }
}
