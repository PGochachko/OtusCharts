//
//  ContentView.swift
//  OtusCharts
//
//  Created by user on 10.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import SwiftUI
import SwiftUICharts
import Combine

import OtusNewsApi
import OtusGithubAPI

final class ChartsViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    private let githubDownloader: FullTotalCountDownloader<GitHubApi>

    @Published private (set) var chartsData: [[Double]] = [[], [], []]
    @Published private (set) var isLoaded = false

    @Published var selectedChart: Int = 0
    
    init(apiServiceLocator: ServiceLocating) {
        githubDownloader = apiServiceLocator.getService()!
        loadAllDataForCharts()
    }
    
    private func isFullDataChartsLoaded() -> Bool {
        let emptyChartData = chartsData.first { $0.isEmpty }
        return emptyChartData == nil
    }
    
    private func loadAllDataForCharts() {
        self.isLoaded = false

        let newsApplePromise = NewsApi.getTotalCount(title: "Apple")
        let newsBitcoinPromise = NewsApi.getTotalCount(title: "bitcoin")
        let newsNginxPromise = NewsApi.getTotalCount(title: "nginx")
        
        Publishers.Zip3(newsApplePromise,newsBitcoinPromise, newsNginxPromise)
            .receive(on: RunLoop.main)
            .sink { result in
                let tupleMirror = Mirror(reflecting: result)
                let elements = tupleMirror.children.map({$0.value as! Double})
                self.chartsData[0] = elements
                self.chartsData[1] = elements
                self.isLoaded = true
        }
        .store(in: &self.subscriptions)
        
        githubDownloader.requestTotalCounts { titleCountDictionary in
            self.chartsData[1] = titleCountDictionary.map{$1}
            self.isLoaded = self.isFullDataChartsLoaded()
        }
        self.chartsData[2] = Histogram().histogram.map{Double($1)}
        self.isLoaded = self.isFullDataChartsLoaded()
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ChartsViewModel
    
    var body: some View {
        VStack {
            Picker(selection: self.$viewModel.selectedChart, label: Text("Charts")) {
                Text("Github").tag(0)
                Text("News").tag(1)
                Text("Histogram").tag(2)
            }
            .frame(alignment: .top)
            .pickerStyle(SegmentedPickerStyle())
            
            if self.viewModel.isLoaded {
                if self.viewModel.selectedChart == 0 {
                    PieChartView(data: self.viewModel.chartsData[self.viewModel.selectedChart], title: "News")
                        .transition(.leftInRightOut)
                        .animation(.easeInOut(duration: 1.0))
                } else if self.viewModel.selectedChart == 1 {
                    BarChartView(data: ChartData(points: self.viewModel.chartsData[self.viewModel.selectedChart]),
                                 title: "Github",
                                 valueSpecifier: "%.2f")
                        .transition(.leftInRightOut)
                        .animation(.easeInOut(duration: 1.0))
                } else if self.viewModel.selectedChart == 2 {
                    LineChartView(data: self.viewModel.chartsData[self.viewModel.selectedChart], title: "Histogram")
                        .transition(.leftInRightOut)
                        .animation(.easeInOut(duration: 1.0))
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity,
               minHeight: 0, maxHeight: .infinity,
               alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ChartsViewModel(apiServiceLocator: ApiServiceLocator()))
    }
}
