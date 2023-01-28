//
//  NetworkManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import Foundation

enum DigimonEndpoint {
    case digimon
    case nameSearch(name: String)
    case levelSearch(level: String)
    case digimonImage(imageUrl: String)

    var endpointURL: String {
        switch self {
            case .digimon, .nameSearch(name: _), .levelSearch(level: _):
                return apiURLString + path
            case .digimonImage(imageUrl: _):
                return path
        }
    }

    private var apiURLString: String {
        "https://digimon-api.vercel.app/api/digimon"
    }

    private var path: String {
        switch self {
            case .digimon:
                return "/"
            case .nameSearch(name: let name):
                return "/name/\(name)"
            case .levelSearch(level: let level):
                return "level/\(level)"
            case .digimonImage(imageUrl: let imageURL):
                return imageURL
        }
    }
}

enum NetworkError: Error {
    case invalidUrl
    case invalidData
}

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    typealias DigimonCompletionClosure = (([Digimon]?, Error?) -> Void)
    typealias DigimonImageCompletionClosure = ((Data?, Error?) -> Void)

    public func fetchAllDigimon(completion: DigimonCompletionClosure?) {
        guard let request = createRequest(for: .digimon) else {
            completion?(nil, NetworkError.invalidUrl)
            return
        }
        executeRequest(request: request, completion: completion)
    }

    public func searchDigimonBy(name digimonName: String, completion: DigimonCompletionClosure?) {
        guard let request = createRequest(for: .nameSearch(name: digimonName)) else {
            completion?(nil, NetworkError.invalidUrl)
            return
        }
        executeRequest(request: request, completion: completion)
    }

    public func searchDigimonBy(level digimonLevel: String, completion: DigimonCompletionClosure?) {
        guard let request = createRequest(for: .levelSearch(level: digimonLevel)) else {
            completion?(nil, NetworkError.invalidUrl)
            return
        }
        executeRequest(request: request, completion: completion)
    }

    public func getImage(from url: String, completion: DigimonImageCompletionClosure?) {
        guard let request = createImageRequest(for: .digimonImage(imageUrl: url)) else {
            completion?(nil, NetworkError.invalidUrl)
            return
        }
        downloadImage(request: request, completion: completion)
    }

    private func createRequest(for digimonEndpoint: DigimonEndpoint) -> URLRequest? {
        guard let url = URL(string: digimonEndpoint.endpointURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func createImageRequest(for digimonEndpoint: DigimonEndpoint) -> URLRequest? {
        guard let url = URL(string: digimonEndpoint.endpointURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func executeRequest<T: Codable>(request: URLRequest, completion: ((T?, Error?) -> Void)?) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data else {
                completion?(nil, error)
                return
            }
            if let decodedResponse = try? JSONDecoder().decode(T.self, from: data) {
                DispatchQueue.main.async {
                    completion?(decodedResponse, nil)
                }
            } else {
                completion?(nil, NetworkError.invalidData)
            }
        }
        dataTask.resume()
    }

    private func downloadImage(request: URLRequest, completion: ((Data?, Error?) -> Void)?) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data else {
                completion?(nil, error)
                return
            }

            if !data.isEmpty {
                DispatchQueue.main.async {
                    completion?(data, nil)
                }
            } else {
                completion?(nil, NetworkError.invalidData)
            }
        }
        dataTask.resume()
    }
}
