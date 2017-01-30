//
//  Network.swift
//  Routefire
//
//  Created by William Robinson on 1/28/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import ReachabilitySwift

final class Network {
  static var reachable: Bool {
    return reachability.isReachable
  }
  
  static private let reachability = Reachability()!
  private init() {}

  static func startNotifier() {
    do {
      try reachability.startNotifier()
    } catch {
      print("error starting network reachability notifier")
    }
  }
  
  static func stopNotifier() {
    reachability.stopNotifier()
  }
}
