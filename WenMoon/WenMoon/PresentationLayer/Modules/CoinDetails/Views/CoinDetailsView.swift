//
//  CoinDetailsView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 07.11.24.
//

import SwiftUI
import Charts

struct CoinDetailsView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CoinDetailsViewModel
    
    @State private var animatedChartData: [ChartData.ChartDataPoint] = []
    @State private var selectedPrice: String
    @State private var selectedDate = ""
    @State private var selectedXPosition: CGFloat?
    @State private var selectedTimeframe: ChartTimeframe = .oneDay
    @State private var showErrorAlert = false
    
    // MARK: - Initializers
    init(coin: CoinData) {
        _viewModel = StateObject(wrappedValue: CoinDetailsViewModel(coin: coin))
        selectedPrice = coin.currentPrice.formattedAsCurrency()
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            let coin = viewModel.coin
            HStack(spacing: 12) {
                if let imageData = coin.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .cornerRadius(8)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 36, height: 36)
                        
                        Text(coin.name.prefix(1))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .brightness(-0.1)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(coin.symbol.uppercased())
                            .font(.headline)
                            .bold()
                        
                        Text("#\(coin.marketCapRank.formattedOrNone())")
                            .font(.caption)
                            .bold()
                    }
                    
                    HStack {
                        Text(selectedPrice)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text(selectedDate)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            ZStack {
                if !animatedChartData.isEmpty {
                    makeChartView(animatedChartData)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .frame(height: 100)
            
            Picker("Select Timeframe", selection: $selectedTimeframe) {
                ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            .scaleEffect(0.85)
            .padding(.vertical, 8)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    makeDetailRow(label: "Market Cap", value: coin.marketCap.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "24h Volume", value: coin.totalVolume.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "Max Supply", value: coin.maxSupply.formattedWithAbbreviation(placeholder: "∞"))
                    makeDetailRow(label: "All-Time High", value: coin.ath.formattedAsCurrency())
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    makeDetailRow(label: "Fully Diluted Market Cap", value: coin.fullyDilutedValuation.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "Circulating Supply", value: coin.circulatingSupply.formattedWithAbbreviation())
                    makeDetailRow(label: "Total Supply", value: coin.totalSupply.formattedWithAbbreviation())
                    makeDetailRow(label: "All-Time Low", value: coin.atl.formattedAsCurrency())
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .onChange(of: selectedTimeframe) { _, timeframe in
            Task {
                await viewModel.fetchChartData(on: timeframe)
            }
        }
        .onChange(of: viewModel.chartData) { _, newData in
            if let newData = newData?.prices {
                withAnimation {
                    animatedChartData = newData
                }
            }
        }
        .onChange(of: viewModel.errorMessage) { _, errorMessage in
            showErrorAlert = errorMessage != nil
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage!),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            Task {
                await viewModel.fetchChartData(on: selectedTimeframe)
            }
        }
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeChartView(_ data: [ChartData.ChartDataPoint]) -> some View {
        let prices = data.map { $0.price }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let priceRange = minPrice...maxPrice
        
        Chart {
            ForEach(data, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Price", dataPoint.price)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.wmPink)
            }
        }
        .chartYScale(domain: priceRange)
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartOverlay { proxy in
            makeChartOverlay(proxy: proxy, data: data)
        }
    }
    
    @ViewBuilder
    private func makeChartOverlay(proxy: ChartProxy, data: [ChartData.ChartDataPoint]) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    LongPressGesture(minimumDuration: .zero)
                        .sequenced(before: DragGesture(minimumDistance: .zero))
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                updateSelectedData(
                                    location: geometry.frame(in: .local).origin,
                                    proxy: proxy,
                                    data: data,
                                    geometry: geometry
                                )
                            case .second(true, let drag):
                                if let location = drag?.location {
                                    updateSelectedData(location: location, proxy: proxy, data: data, geometry: geometry)
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            selectedPrice = viewModel.coin.currentPrice.formattedAsCurrency()
                            selectedDate = ""
                            selectedXPosition = nil
                        }
                )
            
            if let selectedXPosition {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: geometry.size.height + 20)
                        .position(x: selectedXPosition, y: geometry.size.height / 2)
                    
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.6))
                        .frame(width: geometry.size.width - selectedXPosition, height: geometry.size.height + 20)
                        .position(x: selectedXPosition + (geometry.size.width - selectedXPosition) / 2, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    private func updateSelectedData(
        location: CGPoint,
        proxy: ChartProxy,
        data: [ChartData.ChartDataPoint],
        geometry: GeometryProxy
    ) {
        guard location.x >= 0, location.x <= geometry.size.width else {
            selectedXPosition = nil
            return
        }
        
        if let date: Date = proxy.value(atX: location.x) {
            if let closestDataPoint = data.min(by: {
                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
            }) {
                selectedPrice = closestDataPoint.price.formattedAsCurrency()
                selectedXPosition = location.x
                
                let formatType: Date.FormatType
                switch selectedTimeframe {
                case .oneDay:
                    formatType = .timeOnly
                case .oneWeek:
                    formatType = .dateAndTime
                default:
                    formatType = .dateOnly
                }
                selectedDate = closestDataPoint.date.formatted(as: formatType)
            }
        }
    }
    
    @ViewBuilder
    private func makeDetailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.caption)
        }
    }
}

// MARK: - Preview
#Preview {
    CoinDetailsView(coin: CoinData())
}
