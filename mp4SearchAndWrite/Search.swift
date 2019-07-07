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
    let movieSearchURL = "search/movie"
    let movieDetailsURL = "movie/"
    let tvSearchURL = "search/tv"
    let tvEpisodeDetailsURL = "tv/"

    let apiKey = "?api_key=85e1f03168320ecbc2ca14c7a39125a1"

    let urlOptionsLanguage = "&language=en-US"
    let urlOptionsPage = "&page=1"
    let urlOptionsAdult = "&include_adult=false"

    let basePosterUrl = "https://image.tmdb.org/t/p/original"

    func searchForMovieId(withTitle title: String, andYear year: String) -> Int? {
        var movieId: Int?

        let initialUrlString = self.buildMovieSearchUrlString()
        let encodedQueryString = title.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed)

        if let queryString = encodedQueryString,
           let requestUrl = URL(string: initialUrlString + "&year=" + year + "&query=" + queryString) {
            if !queryString.isEmpty {
                consoleIO.writeMessage("Starting search...", to: .log)
                let session = URLSession.shared.dataTask(with: requestUrl) { (movieData, response, error) in
                    if error != nil {
                        consoleIO.writeMessage("Error: Your search was unable to be processed. Try again.")
                        consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                    } else {
                        consoleIO.writeMessage("Your search was successful!", to: .log)
                        if let data = movieData {
                            do {
                                consoleIO.writeMessage("Parsing search results...")
                                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                    consoleIO.writeMessage("Search results were parsed successfully.", to: .log)
                                    let results = json["results"] as! [[String: Any]?]
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

    func getMovieDetails(withId id: Int) -> [String: Any]? {
        var movieDetails: [String: Any]?

        let requestUrlString = self.buildMovieDetailsUrlString(id: id)
        consoleIO.writeMessage("Getting Movie details...", to: .log)
        if let requestUrl = URL(string: requestUrlString) {
            let session = URLSession.shared.dataTask(with: requestUrl) { (movieDetailsData, response, error) in
                if error != nil {
                    consoleIO.writeMessage("Error: Movie Details weren't able to be retrieved")
                    consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                } else {
                    consoleIO.writeMessage("Movie details data was successfully retrieved!", to: .log)
                    if let data = movieDetailsData {
                        do {
                            consoleIO.writeMessage("Parsing details...", to: .log)
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                consoleIO.writeMessage("Movie details were parsed successfully.", to: .log)
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
    
    func searchForTvShowDetails(withTitle title: String) -> [String: Any]? {
        var tvShowId: Int?
        var tvShowName: String?
        var tvShowPosterPath: String?
        
        let initialUrlString = self.buildTvSearchUrlString()
        let encodedQueryString = title.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed)
        
        if let queryString = encodedQueryString,
            let requestUrl = URL(string: initialUrlString + "&query=" + queryString) {
            if !queryString.isEmpty {
                consoleIO.writeMessage("Starting search...", to: .log)
                let session = URLSession.shared.dataTask(with: requestUrl) { (tvShowData, response, error) in
                    if error != nil {
                        consoleIO.writeMessage("Error: Your search was unable to be processed. Try again.")
                        consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                    } else {
                        consoleIO.writeMessage("Your search was successful!", to: .log)
                        if let data = tvShowData {
                            do {
                                consoleIO.writeMessage("Parsing search results...", to: .log)
                                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                    consoleIO.writeMessage("Search results were parsed successfully.", to: .log)
                                    let results = json["results"] as! [[String: Any]?]
                                    if let firstResult = results[0],
                                        let id = firstResult["id"] as? Int,
                                        let name = firstResult["name"] as? String,
                                        let posterPath = firstResult["poster_path"] as? String {
                                            tvShowId = id
                                            tvShowName = name
                                            tvShowPosterPath = posterPath
                                    } else {
                                        consoleIO.writeMessage("Error: Your search did not return any results.\n Make sure the year and title parameters are accurate.", to: .error)
                                    }
                                }
                            } catch {
                                consoleIO.writeMessage("Error: Search results were unable to be parsed successfully. \n Please Try again", to: .error)
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
        let tvShowDetails: Dictionary = ["id": tvShowId!, "name": tvShowName!, "posterPath": tvShowPosterPath!] as [String: Any]
        return tvShowDetails
    }
    
    func getTvEpisodeDetails(withId id: Int, season: String, episode: String) -> [String: Any]? {
        var tvEpisodeDetails: [String: Any]?
        
        let requestUrlString = self.buildTvEpisodeDetailsUrlString(id: id, season: season, episode: episode)
        consoleIO.writeMessage("Getting TV Episode details...", to: .log)
        if let requestUrl = URL(string: requestUrlString) {
            let session = URLSession.shared.dataTask(with: requestUrl) { (tvShowDetailsData, response, error) in
                if error != nil {
                    consoleIO.writeMessage("Error: TV Episode Details weren't able to be retrieved", to: .error)
                    consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                } else {
                    consoleIO.writeMessage("TV Episode details data was successfully retrieved!", to: .log)
                    if let data = tvShowDetailsData {
                        do {
                            consoleIO.writeMessage("Parsing details...")
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                consoleIO.writeMessage("TV Episode details were parsed successfully.", to: .log)
                                tvEpisodeDetails = json
                            }
                        } catch {
                            consoleIO.writeMessage("Error: TV Episode details were unable to be parsed successfully. \n Please Try again", to: .error)
                        }
                    }
                }
                sema.signal()
            }
            
            session.resume()
            sema.wait()
        }
        return tvEpisodeDetails
    }
    
    func getTvShowGenres(withId id: Int) -> [[String: Any]]? {
        var tvShowGenres: [[String: Any]]?
        
        let requestUrlString = self.buildTvShowGenresUrlString(id: id)
        if let requestUrl = URL(string: requestUrlString) {
            let session = URLSession.shared.dataTask(with: requestUrl) { (tvShowData, response, error) in
                if error != nil {
                    consoleIO.writeMessage("Error: TV Episode Details weren't able to be retrieved")
                    consoleIO.writeMessage("Error: URLSession dataTask returned an error: \(String(describing: error))", to: .error)
                } else {
                    consoleIO.writeMessage("TV genre details data was successfully retrieved!", to: .log)
                    if let data = tvShowData {
                        do {
                            consoleIO.writeMessage("Parsing details...", to: .log)
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                consoleIO.writeMessage("TV genre details were parsed successfully.", to: .log)
                                tvShowGenres = json["genres"] as? [[String: Any]]
                            }
                        } catch {
                            consoleIO.writeMessage("Error: TV Episode details were unable to be parsed successfully. \n Please Try again", to: .error)
                        }
                    }
                }
                sema.signal()
            }
            
            session.resume()
            sema.wait()
        }
        return tvShowGenres
    }

    func getPosterData(fromPath path: String) -> Data? {
        var posterData: Data?

        consoleIO.writeMessage("Getting movie poster... ", to: .log)

        let posterUrlString = self.buildPosterUrlString(withPath: path)

        if let requestUrl = URL(string: posterUrlString) {
            do {
                let imageData = try Data.init(contentsOf: requestUrl)
                consoleIO.writeMessage("Poster was successfully retrieved!", to: .log)
                posterData = imageData
            } catch {
                consoleIO.writeMessage("Poster was unable to be retrieved.")
                consoleIO.writeMessage("Poster was unable to be retrieved.", to: .error)
            }
        }
        return posterData
    }

    private func buildMovieDetailsUrlString(id: Int) -> String {
        return baseURL + movieDetailsURL + String(id) + apiKey + urlOptionsLanguage + "&append_to_response=release_dates"
    }

    private func buildMovieSearchUrlString() -> String {
        return baseURL + movieSearchURL + apiKey + urlOptionsLanguage + urlOptionsPage + urlOptionsAdult
    }
    
    private func buildTvEpisodeDetailsUrlString(id: Int, season: String, episode: String) -> String {
        return baseURL + tvEpisodeDetailsURL + String(id) + "/season/" + season + "/episode/" + episode + apiKey + urlOptionsLanguage
    }
    
    private func buildTvSearchUrlString() -> String {
        return baseURL + tvSearchURL + apiKey + urlOptionsLanguage + urlOptionsPage
    }
    
    private func buildTvShowGenresUrlString(id: Int) -> String {
        return baseURL + tvEpisodeDetailsURL + String(id) + apiKey + urlOptionsLanguage
    }

    private func buildPosterUrlString(withPath path: String) -> String {
        return basePosterUrl + path
    }
}
