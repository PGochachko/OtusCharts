//
//  ApiExtensions.swift
//  OtusCharts
//
//  Created by user on 16.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import SwiftUI

import OtusNewsApi
import OtusGithubAPI

protocol TotalCountProtocol {
    static func getTotalCount(title: String, callback: @escaping (Double)->Void)
}

extension SearchAPI: TotalCountProtocol {
    static func getTotalCount(title: String, callback: @escaping (Double)->Void) {
        SearchAPI.searchReposGet(q: title, order: Order.desc) { list, error in
            if let count = list?.totalCount {
                callback(Double(count))
            }
        }
    }
}

extension ArticlesAPI: TotalCountProtocol {
    static func getTotalCount(title: String, callback: @escaping (Double)->Void) {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let stringCurrentDate = formatter.string(from: currentDate)

        ArticlesAPI.everythingGet(q: title, from: stringCurrentDate, sortBy: "publishedAt", apiKey: "fc743db938c646dc9e4be15868526bf7") { list, error in
            if let count = list?.totalResults {
                callback(Double(count))
            }
        }
    }
}

final class FullTotalCountDownloader<ApiType: TotalCountProtocol> {
    private var titleCountDictionary: [String: Double] = [:]
    
    init(titles: [String]) {
        titles.forEach { category in
            self.titleCountDictionary[category] = -1
        }
    }
    
    func requestTotalCounts(callbackLoaded: @escaping ([String: Double])->Void) {
        for title in self.titleCountDictionary.keys {
            ApiType.getTotalCount(title: title) { count in
                self.titleCountDictionary[title] = count
                if (self.isFullTitlesDownloaded()) {
                    callbackLoaded(self.titleCountDictionary)
                }
            }
        }
    }
    
    private func isFullTitlesDownloaded() -> Bool {
        let unloadedTitle = self.titleCountDictionary.first {$1 == -1}
        return unloadedTitle == nil
    }
}
