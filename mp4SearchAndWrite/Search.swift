//
//  Search.swift
//  mp4SearchAndWrite
//
//  Created by Kyle Grieder on 9/4/18.
//  Copyright © 2018 Kyle Grieder. All rights reserved.
//

import Foundation

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
    
    
    func movie(withTitle title: String, andYear year: String) -> Movie? {
        
        var movie = Movie(withYear: NSNumber(value:Int(year)!))
        
        if let movieId = self.searchForMovieId(withTitle: title, andYear: year) {
            let movieDetails = self.searchForMovieDetails(withId: movieId)
            consoleIO.writeMessage("Movie Details \(movieDetails!["poster_path"])")
        }
        
        // add details from movieDetails to Movie
        
        return movie
    }
    
    func searchForMovieId(withTitle title: String, andYear year: String) -> Int? {
        var movieId : Int?
        
        let initialUrlString = self.buildUrlString(forType: "search", withId: nil)
        let encodedQueryString = title.addingPercentEncoding(withAllowedCharacters:.urlPasswordAllowed)
        
        if let queryString = encodedQueryString,
            let requestUrl = URL(string: initialUrlString + "&year=" + year + "&query=" + queryString) {
            if !queryString.isEmpty {
                consoleIO.writeMessage("starting search...")
                let session = URLSession.shared.dataTask(with: requestUrl) { (movieData, response, error) in
                    if error != nil {
                        consoleIO.writeMessage("Error: Your search was unable to be processed. Try again.")
                        consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                    } else {
                        consoleIO.writeMessage("Your search was successful!")
                        if let data = movieData {
                            do {
                                consoleIO.writeMessage("Parsing search results...")
                                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] {
                                    consoleIO.writeMessage("Search results were parsed successfully.")
                                    let results = json["results"] as! [[String : Any]?]
                                    if let firstResult = results[0], let id = firstResult["id"] as? Int {
                                        movieId = id
                                    } else {
                                        consoleIO.writeMessage("Error: Your search did not return any results.\n Make sure the year and title parameters are accurate.")
                                    }
                                }
                            } catch {
                                consoleIO.writeMessage("Error: Search results were unable to be parsed successfully. \n Please Try again")
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
    
    func searchForMovieDetails(withId id: Int) -> [String : Any]? {
        var movieDetails : [String : Any]?
        
        consoleIO.writeMessage("Movie ID \(String(id))")
        
        let requestUrlString = self.buildMovieDetailsUrlString(withId: id)
        
        if let requestUrl = URL(string: requestUrlString) {
            let session = URLSession.shared.dataTask(with: requestUrl) { (movieDetailsData, response, error) in
                if error != nil {
                    consoleIO.writeMessage("Error: Movie Details weren't able to be retrieved")
                    consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                } else {
                    consoleIO.writeMessage("Movie details data was successfully retrieved!")
                    if let data = movieDetailsData {
                        do {
                            consoleIO.writeMessage("Parsing details...")
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] {
                                consoleIO.writeMessage("Movie details were parsed successfully.")
                                consoleIO.writeMessage("Movie details \(json)")
                                movieDetails = json
                            }
                        } catch {
                            consoleIO.writeMessage("Error: Movie details were unable to be parsed successfully. \n Please Try again")
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
    
    private func buildUrlString(forType type:String, withId id:Int?) -> String {
        if id != nil && type == "details" {
            return self.buildMovieDetailsUrlString(withId: id!)
        } else if type == "search" {
            return self.buildMovieSearchUrlString()
        } else {
            return baseURL
        }
    }
    
    private func buildMovieDetailsUrlString(withId id: Int) -> String {
        return baseURL + detailsURL + String(id) + apiKey + urlOptionsLanguage
    }
    
    private func buildMovieSearchUrlString() -> String {
        return baseURL + searchURL + apiKey + urlOptionsLanguage + urlOptionsPage + urlOptionsAdult
    }
}
