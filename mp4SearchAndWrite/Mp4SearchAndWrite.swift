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
    case signature = "s"
    case year = "y"
    case help = "h"
    case path = "p"
    case type = "T"
    case tvShow = "tv show"
    case movie = "movie"
    case unknown = ""

    init(value: String) {
        switch value {
        case "t": self = .title
        case "title": self = .title
        case "s": self = .signature
        case "signature": self = .signature
        case "y": self = .year
        case "year": self = .year
        case "h": self = .help
        case "help": self = .help
        case "p": self = .path
        case "path": self = .path
        case "T": self = .type
        case "type": self = .type
        case "tv-show": self = .tvShow
        case "tv": self = .tvShow
        case "movie": self = .movie
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
            return (OptionType(value: option), option)
        } else if let index = arguments.index(of: "-" + option) {
            let value = arguments[index + 1]
            return (OptionType(value: option), value)
        } else if let index = arguments.index(of: "--" + option) {
            var value: String
            if (option == "tv-show" || option == "tv") {
                return (OptionType(value: "type"), "tv show")
            } else if (option == "movie") {
                return (OptionType(value: "type"), "movie")
            } else {
                value = arguments[index + 1]
            }
            
            return (OptionType(value: option), value)
        } else {
            return (OptionType(value: ""), "")
        }
    }

    func getTerms() -> [String: Any] {
        var terms: Dictionary = ["title": "", "year": "", "signature": "", "path": "", "type": "", "help": false] as [String: Any]

        for argument in CommandLine.arguments {
            let offset = String(argument.suffix(from: argument.index(argument.startIndex, offsetBy: 1))).prefix(1) == "-" ? 2 : 1
            let (option, value) = getOption(String(argument.suffix(from: argument.index(argument.startIndex, offsetBy: offset))))
            
            if (option == .tvShow || option == .movie) {
                terms["type"] = option
            } else {
                switch option {
                case .title: terms["title"] = value
                case .signature: terms["signature"] = value
                case .year: terms["year"] = value
                case .path: terms["path"] = getAbsolutePath(path: value)
                case .type: terms["type"] = value.lowercased()
                case .help: terms["help"] = true
                default: break
                }
            }
        }
        return terms
    }
    
    func getAbsolutePath(path: String) -> String {
        var absolutePath = path
        let fileName = path.split(separator: "/").last
        
        if let fileNameSubstring = fileName {
            let fileNameString = String(fileNameSubstring)
        
            if (path.hasPrefix("~")) {
                // get home directory
                let home = FileManager.default.homeDirectoryForCurrentUser.relativePath
                if let relPath = path.split(separator: "~").last {
                    absolutePath = home + relPath
                }
            } else if (!path.hasPrefix("/")) {
                //get current working directory
                let cwd = FileManager.default.currentDirectoryPath
                    
                absolutePath = cwd + "/" + fileNameString
            }
        }
        return absolutePath
    }
}
