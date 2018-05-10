//
//  Connectivity.swift
//  Streams
//
//  Created by Igor Karyi on 19.04.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import Foundation
import Alamofire

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
