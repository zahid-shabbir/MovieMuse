//
//  NetworkManager.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//

import Foundation
protocol WebServiceProtocol {
    var baseUrl: String { get }
    var apiKey: String { get }
    var endPoint: String { get }
    var headers: [String: String] { get }
    var timeoutInterval: TimeInterval { get }
    var httpMethod: HTTPMethod { get }

    // func getRequest(params: ParamsType) -> URLRequest?
}

extension WebServiceProtocol {
    var baseUrl: String {
        "https://api.themoviedb.org"
    }

    var apiKey: String { "e5ea3092880f4f3c25fbc537e9b37dc1" }

    var headers: [String: String] { [:] }

    var timeoutInterval: TimeInterval { TimeInterval(30) }

    func prepareRequest(params: ParamsType) -> URLRequest? {
        // Create the URL using baseUrl and endPoint
        guard let url = URL(string: baseUrl + endPoint) else {
            return nil
        }
        // print("📡 request Url \(url.absoluteString) 📡")
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        // Set the headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Set the timeout interval
        request.timeoutInterval = timeoutInterval

        // Set the params in the request body, if provided
        if let params = params {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                print("Failed to serialize params: \(error)")
            }
        }

        return request
    }
}
