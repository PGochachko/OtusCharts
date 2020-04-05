//
//  ApiExtensions.swift
//  OtusCharts
//
//  Created by user on 16.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import SwiftUI
import Combine

import OtusNewsApi
import OtusGithubAPI

struct TotalCountData: Codable {
    let totalResults: Int
}

protocol NewsApiProtocol {
    static func getTotalCount(title: String) -> Future<Double, Never>
}
protocol GitHubApiProtocol {
    static func getTotalCount(title: String, callback: @escaping (Double)->Void)
}


class GitHubApi: GitHubApiProtocol {
    static func getTotalCount(title: String, callback: @escaping (Double)->Void) {
        SearchAPI.searchReposGet(q: title, order: Order.desc) { list, error in
            if let count = list?.totalCount {
                callback(Double(count))
            }
        }
    }
}

class NewsApi: NewsApiProtocol {
    static func getTotalCount(title: String) -> Future<Double, Never> {
        return Future<Double, Never> { promise in
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let stringYesterday = formatter.string(from: yesterday)
            
            guard let url = URL(string: "http://newsapi.org/v2/everything?q=\(title)&from=\(stringYesterday)&sortBy=publishedAt&apiKey=b8292fe9971a4230902942e9fe51bd9e")
                else { return }
            
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                do {
                    if let error = error {
                        print(error)
                    } else if let data = data {
                        let decoder = JSONDecoder()
                        let totalCountData = try decoder.decode(TotalCountData.self, from: data)
                        let result = Double(totalCountData.totalResults)
                        promise(.success(result))
                    }
                } catch (let e) {
                    print(e)
                }
            })
            task.resume()
        }
    }
}

final class FullTotalCountDownloader<ApiType: GitHubApi> {
    private var titleCountDictionary: [String: Double] = [:]
    private let subject = PassthroughSubject<[String : Double], Never>()
    
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
