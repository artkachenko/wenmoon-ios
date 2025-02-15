//
//  AccountViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import Foundation
import UIKit.UIApplication
import FirebaseAuth

final class AccountViewModel: BaseViewModel {
    // MARK: - Nested Types
    enum LoginState: Equatable {
        case signedIn(_ userID: String? = nil)
        case signedOut
    }
    
    enum CommunityLinks: CaseIterable {
        case x, telegram, reddit
        
        var url: URL? {
            switch self {
            case .x:
                return URL(string: "https://x.com/wenmoon_app")
            case .telegram:
                return URL(string: "https://t.me/wenmoon_app")
            case .reddit:
                return URL(string: "https://www.reddit.com/r/wenmoon_app")
            }
        }
        
        var imageName: String {
            switch self {
            case .x: return "x.logo"
            case .telegram: return "telegram.logo"
            case .reddit: return "reddit.logo"
            }
        }
    }
    
    // MARK: - Properties
    private let googleSignInService: GoogleSignInService
    private let twitterSignInService: TwitterSignInService
    
    @Published var settings: [Setting] = []
    @Published var loginState: LoginState = .signedOut
    @Published var communityLinks = CommunityLinks.allCases
    
    @Published private(set) var isGoogleAuthInProgress = false
    @Published private(set) var isTwitterAuthInProgress = false
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            googleSignInService: GoogleSignInServiceImpl(),
            twitterSignInService: TwitterSignInServiceImpl()
        )
    }
    
    init(
        googleSignInService: GoogleSignInService,
        twitterSignInService: TwitterSignInService,
        firebaseAuthService: FirebaseAuthService? = nil,
        userDefaultsManager: UserDefaultsManager? = nil
    ) {
        self.googleSignInService = googleSignInService
        self.twitterSignInService = twitterSignInService
        super.init(firebaseAuthService: firebaseAuthService, userDefaultsManager: userDefaultsManager)
    }
    
    // MARK: - Authentication
    func signInWithGoogle() {
        isGoogleAuthInProgress = true
        
        guard
            let clientID = firebaseAuthService.clientID,
            let rootViewController = UIApplication.rootViewController
        else {
            return
        }
        
        googleSignInService.configure(clientID: clientID)
        googleSignInService.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard
                let self,
                let user = result?.user,
                let idToken = user.idToken?.tokenString,
                error == nil
            else {
                self?.isGoogleAuthInProgress = false
                return
            }
            
            let credential = googleSignInService.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            signIn(with: credential) {
                self.isGoogleAuthInProgress = false
            }
        }
        
        triggerImpactFeedback()
    }
    
    func signInWithTwitter() {
        isTwitterAuthInProgress = true
        
        twitterSignInService.signIn { [weak self] credential, error in
            guard
                let self,
                let credential,
                error == nil
            else {
                self?.isTwitterAuthInProgress = false
                return
            }
            
            signIn(with: credential) {
                self.isTwitterAuthInProgress = false
            }
        }
        
        triggerImpactFeedback()
    }
    
    func signOut() {
        do {
            try firebaseAuthService.signOut()
            loginState = .signedOut
        } catch {
            setError(error)
        }
    }
    
    func fetchAuthState() {
        if let userID = firebaseAuthService.userID {
            loginState = .signedIn(userID)
        } else {
            loginState = .signedOut
        }
    }
    
    // MARK: - Settings
    func fetchSettings() {
        settings = [
            Setting(type: .startScreen, selectedOption: getSavedSetting(of: .startScreen)),
            Setting(type: .language, selectedOption: getSavedSetting(of: .language)),
            Setting(type: .currency, selectedOption: getSavedSetting(of: .currency)),
            Setting(type: .privacyPolicy)
        ]
        
        if case .signedIn = loginState {
            settings.append(Setting(type: .signOut))
        }
    }
    
    func updateSetting(of type: Setting.SettingType, with value: Int) {
        if let index = settings.firstIndex(where: { $0.type == type }) {
            settings[index].selectedOption = value
            setSetting(value, of: settings[index].type)
        }
    }
    
    func getSetting(of type: Setting.SettingType) -> Setting? {
        settings.first(where: { $0.type == type })
    }
    
    func getSettingOptionTitle(for settingType: Setting.SettingType, with selectedOption: Int) -> String {
        settingType.options[selectedOption].title
    }
    
    // MARK: - Private Methods
    private func signIn(with credential: AuthCredential, completion: @escaping (() -> Void)) {
        firebaseAuthService.signIn(with: credential) { [weak self] authResult, error in
            if let error {
                self?.setError(error)
            } else {
                self?.loginState = .signedIn(authResult?.user.displayName)
            }
            completion()
        }
    }
    
    private func getSavedSetting(of type: Setting.SettingType) -> Int {
        (try? userDefaultsManager.getObject(forKey: .setting(ofType: type), objectType: Int.self)) ?? .zero
    }
    
    private func setSetting(_ setting: Int, of type: Setting.SettingType) {
        try? userDefaultsManager.setObject(setting, forKey: .setting(ofType: type))
    }
}

struct Setting: Identifiable, Hashable {
    var id = UUID().uuidString
    let type: SettingType
    var selectedOption: Int? = nil
}

extension Setting {
    enum SettingType: Int, CaseIterable {
        case startScreen
        case language
        case currency
        case privacyPolicy
        case signOut
        
        var title: String {
            switch self {
            case .startScreen:
                return "Start Screen"
            case .language:
                return "Language"
            case .currency:
                return "Currency"
            case .privacyPolicy:
                return "Privacy Policy"
            case .signOut:
                return "Sign Out"
            }
        }
        
        var imageName: String {
            switch self {
            case .startScreen:
                return "house"
            case .language:
                return "globe"
            case .currency:
                return "dollarsign.circle"
            case .privacyPolicy:
                return "doc.text"
            case .signOut:
                return "rectangle.portrait.and.arrow.right"
            }
        }
        
        var options: [SettingOption] {
            switch self {
            case .startScreen:
                return StartScreen.allCases.map { SettingOption(title: $0.title, imageName: $0.imageName, value: $0.rawValue) }
            case .language:
                return Language.allCases.map { SettingOption(title: $0.title, value: $0.rawValue, isEnabled: $0 == .english) }
            case .currency:
                return Currency.allCases.map { SettingOption(title: $0.title, value: $0.rawValue, isEnabled: $0 == .usd) }
            default:
                return []
            }
        }
        
        var defaultOption: SettingOption? {
            switch self {
            case .startScreen:
                let startScreen = StartScreen.coins
                return SettingOption(title: startScreen.title, value: startScreen.rawValue)
            case .language:
                let language = Language.english
                return SettingOption(title: language.title, value: language.rawValue)
            case .currency:
                let currency = Currency.usd
                return SettingOption(title: currency.title, value: currency.rawValue)
            default:
                return nil
            }
        }
    }
}

extension Setting.SettingType {
    enum StartScreen: Int, CaseIterable {
        case coins
        case portfolio
        case compare
        case education
        
        var title: String {
            switch self {
            case .coins: return "Coins"
            case .portfolio: return "Portfolio"
            case .compare: return "Compare"
            case .education: return "Education"
            }
        }
        
        var imageName: String {
            switch self {
            case .coins: return "coins"
            case .portfolio: return "bag"
            case .compare: return "arrows.swap"
            case .education: return "books"
            }
        }
    }
    
    enum Language: Int, CaseIterable {
        case english
        case spanish
        case german
        case french
        
        var title: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Spanish"
            case .german: return "German"
            case .french: return "French"
            }
        }
    }
    
    enum Currency: Int, CaseIterable {
        case usd
        case eur
        case gbp
        case jpy
        
        var title: String {
            switch self {
            case .usd: return "USD"
            case .eur: return "EUR"
            case .gbp: return "GBP"
            case .jpy: return "JPY"
            }
        }
    }
}

struct SettingOption: Hashable {
    let title: String
    let imageName: String?
    let value: Int
    let isEnabled: Bool
    
    init(title: String, imageName: String? = nil, value: Int, isEnabled: Bool = true) {
        self.title = title
        self.imageName = imageName
        self.value = value
        self.isEnabled = isEnabled
    }
}
