//
//  NetworkManager.swift
//  MyWordle
//
//  Created by Kshitij Srivastava on 01/02/25.
//

import Foundation

final class NetworkManager {
    private static let urlSession = URLSession.shared
    
    // Function to create a request
    func createRequest(
        url: URL,
        method: HTTPMethod = .GET,
        body: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if body != nil {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        return request
    }
    
    // Function to perform a request
    func makeRequest(request: URLRequest) async -> Data? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                return data
            }
            else {
                throw URLError(.badServerResponse)
            }
        }
        catch {
            print("Error: \(error)")
        }
        return nil
    }
    
}

enum HTTPMethod: String {
    case GET
    case POST
}
