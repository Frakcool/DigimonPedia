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
            case .digimon, .nameSearch, .levelSearch:
                return apiURLString + path
            case .digimonImage:
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
                return "/level/\(level.percentageEncoded())"
            case .digimonImage(imageUrl: let imageURL):
                return imageURL
        }
    }
}

enum NetworkError: Error {
    case invalidUrl
    case invalidData
}

struct NetworkManager {
    public func fetchAllDigimon() async throws -> [Digimon] {
        guard let request = createRequest(for: .digimon) else {
            throw NetworkError.invalidUrl
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Digimon].self, from: data)
    }

    public func searchDigimonBy(name digimonName: String) async throws -> [Digimon] {
        guard let request = createRequest(for: .nameSearch(name: digimonName)) else {
            throw NetworkError.invalidUrl
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Digimon].self, from: data)
    }

    public func searchDigimonBy(level digimonLevel: String) async throws -> [Digimon] {
        guard let request = createRequest(for: .levelSearch(level: digimonLevel)) else {
            throw NetworkError.invalidUrl
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Digimon].self, from: data)
    }

    public func getImage(from url: String) async throws -> Data {
        guard let request = createRequest(for: .digimonImage(imageUrl: url)) else {
            throw NetworkError.invalidUrl
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    private func createRequest(for digimonEndpoint: DigimonEndpoint) -> URLRequest? {
        guard let url = URL(string: digimonEndpoint.endpointURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func executeRequest<T: Codable>(request: URLRequest) async throws -> T? {
        let session = URLSession(configuration: .default)
        let (data, response) = try await session.data(for: request)

        if self.isImage(mimeType: response.mimeType) {
            return data as? T
        } else {
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw NetworkError.invalidData
            }
        }
    }

    private func isImage(mimeType: String?) -> Bool {
        mimeType == "image/jpeg"
    }
}

extension String {
    func percentageEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
