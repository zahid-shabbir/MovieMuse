//
//  NetworkError.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 19/05/2023.
//

import Foundation
enum NetworkError: Error {
    case noInternetConnection
    case timeout
    case invalidURL
    case serverUnavailable
    case unauthorized
    case forbidden
    case notFound
    case badRequest
    case internalServerError
    case dnsLookupFailed
    case noData
    case parsingError
    case unknownError(Error)

    var errorMessage: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings and try again."
        case .timeout:
            return "Request timed out. Please try again later."
        case .invalidURL:
            return "Invalid URL. Please verify the URL and try again."
        case .serverUnavailable:
            return "The server is currently unavailable. Please try again later."
        case .unauthorized:
            return "Unauthorized. Please authenticate and try again."
        case .forbidden:
            return "Access to the requested resource is forbidden."
        case .notFound:
            return "The requested resource was not found."
        case .badRequest:
            return "Bad request. Please check your request parameters and try again."
        case .internalServerError:
            return "Internal server error. Please try again later."
        case .dnsLookupFailed:
            return "DNS lookup failed. Please check your internet connection and try again."
        case .noData:
            return "No data received. Please try again later or contact support."
        case .parsingError:
            return "Error occurred while parsing the response data. Please try again later or contact support."
        case let .unknownError(error):
            return "Unknown Error: \(error.localizedDescription)"
        }
    }
}
