//
//  ReachabilityManager.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 22/05/2023.
//

import Foundation
import Network

class ReachabilityManager {
    static let shared = ReachabilityManager()
    private let networkMonitor: NWPathMonitor
    private let monitorQueue = DispatchQueue.global()
    var isNetworkAvailable: Bool = true
    var connectionType: ConnectionType = .wifi

    private init() {
        networkMonitor = NWPathMonitor()
        networkMonitor.start(queue: monitorQueue)
    }

    func startMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
            self?.connectionType = self?.getConnectionType(for: path) ?? .unknown
        }
    }

    func stopMonitoring() {
        networkMonitor.cancel()
    }

    private func getConnectionType(for path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        }

        return .unknown
    }
}

public enum ConnectionType {
    case wifi
    case ethernet
    case cellular
    case unknown
}
