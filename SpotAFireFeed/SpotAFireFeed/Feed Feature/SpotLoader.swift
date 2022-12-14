// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public protocol SpotLoader {
    typealias Result = Swift.Result<[Spot], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
