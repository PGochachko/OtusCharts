//
//  ApiServiceLocator.swift
//  OtusCharts
//
//  Created by Павел on 04.04.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation

protocol ServiceLocating {
    func getService<T>() -> T?
}

final class ApiServiceLocator: ServiceLocating {
    public static let shared: ApiServiceLocator = ApiServiceLocator()
    
    private lazy var services: Dictionary<String, Any> = [:]
    
    private func getTypeName(some: Any) -> String {
        return (some is Any.Type) ?
        "\(some)" : "\(type(of: some))"
    }
    
    func addService<T>(service: T) {
        let key = getTypeName(some: service)
        services[key] = service
    }
    
    func getService<T>() -> T? {
        let key = getTypeName(some: T.self)
        return services[key] as? T
    }
    
}
