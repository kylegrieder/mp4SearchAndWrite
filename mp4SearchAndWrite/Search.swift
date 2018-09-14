//
//  Search.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation
import Cocoa

let consoleIO = ConsoleIO()
var sema = DispatchSemaphore(value: 0)

class Search {
    
    let baseURL = "https://api.themoviedb.org/3/"
    let searchURL = "search/movie"
    let detailsURL = "movie/"
    
    let apiKey = "?api_key=85e1f03168320ecbc2ca14c7a39125a1"
    
    let urlOptionsLanguage = "&language=en-US"
    let urlOptionsPage = "&page=1"
    let urlOptionsAdult = "&include_adult=false"
    
    let basePosterUrl = "https://image.tmdb.org/t/p/original"
    
    func searchForMovieId(withTitle title: String, andYear year: String) -> Int? {
        var movieId : Int?
        
        let initialUrlString = self.buildUrlString(forType: "search", withId: nil, orPosterPath: nil)
        let encodedQueryString = title.addingPercentEncoding(withAllowedCharacters:.urlPasswordAllowed)
        
        if let queryString = encodedQueryString,
            let requestUrl = URL(string: initialUrlString + "&year=" + year + "&query=" + queryString) {
            if !queryString.isEmpty {
                consoleIO.writeMessage("Starting search...")
                let session = URLSession.shared.dataTask(with: requestUrl) { (movieData, response, error) in
                    if error != nil {
                        consoleIO.writeMessage(" Error: Your search was unable to be processed. Try again.")
                        consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                    } else {
                        consoleIO.writeMessage(" Your search was successful!")
                        if let data = movieData {
                            do {
                                consoleIO.writeMessage("  Parsing search results...")
                                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] {
                                    consoleIO.writeMessage("   Search results were parsed successfully.")
                                    let results = json["results"] as! [[String : Any]?]
                                    if let firstResult = results[0], let id = firstResult["id"] as? Int {
                                        movieId = id
                                    } else {
                                        consoleIO.writeMessage("   Error: Your search did not return any results.\n Make sure the year and title parameters are accurate.")
                                    }
                                }
                            } catch {
                                consoleIO.writeMessage("  Error: Search results were unable to be parsed successfully. \n Please Try again")
                            }
                        }
                    }
                    sema.signal()
                }
                
                session.resume()
                sema.wait()
                
            } else {
                consoleIO.writeMessage("Error: You didn't include a title to search.")
                consoleIO.writeMessage("Error: No query string", to: .error)
            }
        }
        return movieId
    }
    
    func getMovieDetails(withId id: Int) -> [String : Any]? {
        var movieDetails : [String : Any]?
        
        let requestUrlString = self.buildMovieDetailsUrlString(withId: id)
        consoleIO.writeMessage("Getting Movie details...")
        if let requestUrl = URL(string: requestUrlString) {
            let session = URLSession.shared.dataTask(with: requestUrl) { (movieDetailsData, response, error) in
                if error != nil {
                    consoleIO.writeMessage(" Error: Movie Details weren't able to be retrieved")
                    consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                } else {
                    consoleIO.writeMessage(" Movie details data was successfully retrieved!")
                    if let data = movieDetailsData {
                        do {
                            consoleIO.writeMessage("  Parsing details...")
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] {
                                consoleIO.writeMessage("   Movie details were parsed successfully.")
                                movieDetails = json
                            }
                        } catch {
                            consoleIO.writeMessage("   Error: Movie details were unable to be parsed successfully. \n Please Try again")
                        }
                    }
                }
                sema.signal()
            }
            
            session.resume()
            sema.wait()
        }
        return movieDetails
    }
    
    func getMoviePosterData(fromPath path: String) -> Data? {
        var posterData: Data?
        
        consoleIO.writeMessage("Getting movie poster... ")
        
        let posterUrlString = self.buildUrlString(forType: "poster", withId: nil, orPosterPath: path)
        
        if let requestUrl = URL(string: posterUrlString) {
            do {
                let imageData = try Data.init(contentsOf: requestUrl)
                consoleIO.writeMessage(" Poster was successfully retrieved!")
                posterData = imageData
            } catch {
                consoleIO.writeMessage(" Poster was unable to be retrieved.")
                consoleIO.writeMessage(" Poster was unable to be retrieved.", to: .error)
            }
        }
        return posterData
    }
    
    private func buildUrlString(forType type:String, withId id:Int?, orPosterPath path: String?) -> String {
        if id != nil && type == "details" {
            return self.buildMovieDetailsUrlString(withId: id!)
        } else if type == "search" {
            return self.buildMovieSearchUrlString()
        } else if path != nil && type == "poster" {
            return self.buildPosterUrlString(withPath: path!)
        } else {
            return baseURL
        }
    }
    
    private func buildMovieDetailsUrlString(withId id: Int) -> String {
        return baseURL + detailsURL + String(id) + apiKey + urlOptionsLanguage + "&append_to_response=release_dates"
    }
    
    private func buildMovieSearchUrlString() -> String {
        return baseURL + searchURL + apiKey + urlOptionsLanguage + urlOptionsPage + urlOptionsAdult
    }
    
    private func buildPosterUrlString(withPath path: String) -> String {
        return basePosterUrl + path
    }
}
