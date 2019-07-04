//
//  main.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

let mp4SearchAndWrite = Mp4SearchAndWrite()
let helpers = Helpers()

func main() {
    
    if (CommandLine.argc < 2) {
        mp4SearchAndWrite.staticMode()
    } else {
        let terms = mp4SearchAndWrite.getTerms()
    
        if (terms["help"] as? Bool ?? false) {
            mp4SearchAndWrite.helpMode()
        } else {
            let type = terms["type"] as? String
            
            if (type == "movie") {
            
                if let filePath = terms["path"] as? String {
                    if (FileManager.default.fileExists(atPath: filePath)) {
                        var title: String
                        var year: String
                    
                        let titleTerm = terms["title"] as? String
                        let yearTerm = terms["year"] as? String
                    
                        if (!(titleTerm ?? "").isEmpty) {
                            title = titleTerm as! String
                        } else {
                            if let titleLast = filePath.split(separator: "/").last,
                                let titleFirst = String(titleLast).split(separator: "(").first {
                                title = String(titleFirst)
                            } else {
                                consoleIO.writeMessage("Couldn't parse title. Make sure your format is: \"Movie Name (MovieYear) - example: The Avengers (2012)\"")
                                exit(1)
                            }
                        }
                    
                        if (!(yearTerm ?? "").isEmpty) {
                            year = yearTerm as! String
                        } else {
                            if let yearLast = filePath.split(separator: "/").last,
                                let yearLastAgain = String(yearLast).split(separator: "(").last,
                                let yearFirst = String(yearLastAgain).split(separator: ")").first {
                                 year = String(yearFirst)
                            } else {
                                consoleIO.writeMessage("Couldn't parse year. Make sure your format is: \"Movie Name (MovieYear) - example: The Avengers (2012)\"")
                                exit(1)
                            }
                        }
                    
                        let movie = Movie(withTitle: title, andYear: year)
                        
                        let artworkPath = "/" + filePath.split(separator: "/").dropLast().joined(separator: "/") + "/poster-" + title + ".jpg"
                        helpers.savePosterImage(fromData: movie.artworkData, toPath: artworkPath)
                        
                        if let title = movie.title,
                            let genre = movie.genre,
                            let releaseDate = movie.releaseDate,
                            let longDesc = movie.longDesc,
                            let storeDesc = movie.storeDesc,
                            let mpaaCert = movie.mpaaCertification {
                            
                            let arguments = [filePath, artworkPath, title, genre, releaseDate, longDesc, storeDesc, mpaaCert, movie.stik]
                            helpers.mp4WriteScript(withArguments: arguments)
                        } else {
                            consoleIO.writeMessage("The Movie DB failed to return some of the information for the movie you entered. Make sure the title and year are correct and try again.")
                            exit(1)
                        }
                    } else {
                        consoleIO.writeMessage("It looks like the path you provided might be wrong. There isn't a file there.")
                        exit(1)
                    }
                } else {
                    consoleIO.writeMessage("You forgot to include a path. (ie. -p \"/Users/name/Downloads/The Avengers (2012).mp4\")")
                    exit(1)
                }
            } else if (type == "tv") {
            
            } else {
                consoleIO.writeMessage("You didn't include a type. (ie. -T \"Movie\")")
                exit(1)
            }
        }
    }
}
main()
