//
//  Reachability.swift
//  GiphyAssignment
//
//  Created by Sri on 13/06/22.
//

import Network


///
///The `Rechability` used to identify whether network is reachable.
///

final class Reachability {

    fileprivate var monitor: NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.start(queue: .global())
        return monitor
    }()

    ///
    ///  Will return the network rechability status
    ///
    var isReachable: Bool {
        return monitor.currentPath.status == .satisfied
    }

    static let shared = Reachability()
    private init() {}
}

