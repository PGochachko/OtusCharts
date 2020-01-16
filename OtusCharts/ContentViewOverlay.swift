//
//  ContentViewOverlay.swift
//  OtusCharts
//
//  Created by user on 16.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct ContentViewOverlay: View {
    @EnvironmentObject var viewModel: ChartsViewModel
    
    var body: some View {
        VStack {
            if self.viewModel.isLoaded {
                PieChartView(data: self.viewModel.chartsData[0], title: "News")
                    .transition(.leftInRightOut)
                    .animation(.easeInOut(duration: 1.0))
                
                BarChartView(data: ChartData(points: self.viewModel.chartsData[1]),
                             title: "Github",
                             valueSpecifier: "%.2f")
                    .transition(.leftInRightOut)
                    .animation(.easeInOut(duration: 1.0))

                LineChartView(data: self.viewModel.chartsData[2], title: "Histogram")
                    .transition(.leftInRightOut)
                    .animation(.easeInOut(duration: 1.0))
            }
            Spacer()
            Button("Close") {
                App.instance.hiddenOverlayWindow()
            }
        }
    }
}

struct ContentViewOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewOverlay()
    }
}
