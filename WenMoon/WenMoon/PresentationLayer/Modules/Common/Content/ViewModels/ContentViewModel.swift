//
//  ContentViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 15.01.25.
//

import Foundation

final class ContentViewModel: BaseViewModel {
    // MARK: - Properties
    private let coinScannerService: CoinScannerService
    
    @Published var startScreenIndex: Int = .zero
    @Published private(set) var globalMarketDataItems: [GlobalMarketDataItem] = []
    
    var isAllMarketDataItemsFetched: Bool {
        globalMarketDataItems.count == 6
    }
    
    // MARK: - Initializers
    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl())
    }
    
    init(
        coinScannerService: CoinScannerService,
        appLaunchProvider: AppLaunchProvider? = nil
    ) {
        self.coinScannerService = coinScannerService
        super.init(appLaunchProvider: appLaunchProvider)
    }
    
    // MARK: - Internal Methods
    func fetchStartScreen() {
        startScreenIndex = (try? userDefaultsManager.getObject(forKey: .setting(ofType: .startScreen), objectType: Int.self)) ?? .zero
    }
    
    @MainActor
    func fetchAllGlobalMarketData() async {
        do {
            globalMarketDataItems.removeAll()
            
            async let fearAndGreedTask = coinScannerService.getFearAndGreedIndex()
            async let cryptoMarketTask = coinScannerService.getCryptoGlobalMarketData()
            async let globalMarketTask = coinScannerService.getGlobalMarketData()
            
            let (fearAndGreedIndex, cryptoGlobalMarketData, globalMarketData) = try await (
                fearAndGreedTask,
                cryptoMarketTask,
                globalMarketTask
            )
            
            guard let fearAndGreedData = fearAndGreedIndex.data.first else { return }
            let fearAndGreedItem = GlobalMarketDataItem(
                type: .fearAndGreedIndex,
                value: "\(fearAndGreedData.value) \(fearAndGreedData.valueClassification)"
            )
            
            guard let btcDominance = cryptoGlobalMarketData.data.marketCapPercentage["btc"] else { return }
            let btcDominanceItem = GlobalMarketDataItem(
                type: .btcDominance,
                value: btcDominance.formattedAsPercentage(includePlusSign: false)
            )
            
            let marketItems = [
                GlobalMarketDataItem(
                    type: .cpi,
                    value: globalMarketData.cpiPercentage.formattedAsPercentage(includePlusSign: false)
                ),
                GlobalMarketDataItem(
                    type: .nextCPI,
                    value: globalMarketData.nextCPIDate.formatted(as: .dateOnly)
                ),
                GlobalMarketDataItem(
                    type: .interestRate,
                    value: globalMarketData.interestRatePercentage.formattedAsPercentage(includePlusSign: false)
                ),
                GlobalMarketDataItem(
                    type: .nextFOMCMeeting,
                    value: globalMarketData.nextFOMCMeetingDate.formatted(as: .dateOnly)
                )
            ]
            
            let allItems = [fearAndGreedItem, btcDominanceItem] + marketItems
            let newItems = allItems.filter { !globalMarketDataItems.contains($0) }
            globalMarketDataItems.append(contentsOf: newItems)
        } catch {
            setError(error)
            globalMarketDataItems.removeAll()
        }
    }
}

struct GlobalMarketDataItem: Hashable {
    // MARK: - Nested Types
    enum ItemType: CaseIterable {
        case fearAndGreedIndex
        case btcDominance
        case cpi
        case nextCPI
        case interestRate
        case nextFOMCMeeting
        
        var title: String {
            switch self {
            case .fearAndGreedIndex: return "Fear/Greed:"
            case .btcDominance: return "BTC Dom:"
            case .cpi: return "CPI:"
            case .nextCPI: return "Next CPI:"
            case .interestRate: return "Int. Rate:"
            case .nextFOMCMeeting: return "Next FOMC:"
            }
        }
    }
    
    // MARK: - Properties
    let type: ItemType
    let value: String
}
