//
//  ServiceManager.swift .swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 16/05/2023.
//
import Combine
import Foundation

/// A Generic Functions to fetch data using URLSession
/// - Parameters:
///   - requestType: an enum of requests i.e `Login`, `auth service` etc
///   - params: a doctionary of params defualt is nil
///   - completion: a completion that returns parsed modal of type codable that's sent and error message of type string
/// - Returns: it returns nothing but through `completion`

func makeRequest<T: Codable>(for service: WebServiceProtocol, params: ParamsType = nil, completion: @escaping (Result<T, NetworkError>) -> Void) -> AnyCancellable {
    guard let urlRequest = service.prepareRequest(params: params) else {
        DispatchQueue.main.async {
            completion(.failure(.badRequest))
        }
        return AnyCancellable {}
    }

    let publisher = URLSession.shared
        .dataTaskPublisher(for: urlRequest)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200 ..< 300 ~= httpResponse.statusCode else {
                throw NetworkError.serverUnavailable
            }
            // data.printPretty()
            return data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { error in
            if let decodingError = error as? DecodingError {
                return decodingError.handle()
            } else if error is URLError {
                return NetworkError.noData
            } else {
                return NetworkError.unknownError(error)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()

    return publisher
        .sink { completionResult in
            switch completionResult {
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .finished:
                break
            }
        } receiveValue: { value in
            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
}

extension DecodingError {
    func handle() -> NetworkError {
        switch self {
        case let .dataCorrupted(context):
            print("Data corrupted: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
            return NetworkError.parsingError
        case let .keyNotFound(key, context):
            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
            return NetworkError.parsingError
        case let .typeMismatch(type, context):
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
            return NetworkError.parsingError
        case let .valueNotFound(value, context):
            print("Value '\(value)' not found: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
            return NetworkError.parsingError
        default:
            return NetworkError.unknownError(self)
        }
    }
}
