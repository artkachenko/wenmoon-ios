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
    enum AuthState {
        case authenticated(_ account: Account?)
        case unauthenticated
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
    private let firebaseAuthService: FirebaseAuthService
    private let appleSignInService: AppleSignInService
    private let googleSignInService: GoogleSignInService
    private let twitterSignInService: TwitterSignInService
    private let accountService: AccountService
    
    @Published var authState: AuthState = .unauthenticated
    @Published var settings: [Setting] = []
    @Published var communityLinks = CommunityLinks.allCases
    
    @Published private(set) var isAppleAuthInProgress = false
    @Published private(set) var isGoogleAuthInProgress = false
    @Published private(set) var isTwitterAuthInProgress = false
    
    var account: Account? {
        if case .authenticated(let account) = authState {
            return account
        }
        return nil
    }
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            firebaseAuthService: FirebaseAuthServiceImpl(),
            appleSignInService: AppleSignInServiceImpl(),
            googleSignInService: GoogleSignInServiceImpl(),
            twitterSignInService: TwitterSignInServiceImpl(),
            accountService: AccountServiceImpl()
        )
    }
    
    init(
        firebaseAuthService: FirebaseAuthService,
        appleSignInService: AppleSignInService,
        googleSignInService: GoogleSignInService,
        twitterSignInService: TwitterSignInService,
        accountService: AccountService,
        appLaunchProvider: AppLaunchProvider? = nil,
        userDefaultsManager: UserDefaultsManager? = nil
    ) {
        self.firebaseAuthService = firebaseAuthService
        self.googleSignInService = googleSignInService
        self.twitterSignInService = twitterSignInService
        self.appleSignInService = appleSignInService
        self.accountService = accountService
        super.init(appLaunchProvider: appLaunchProvider, userDefaultsManager: userDefaultsManager)
    }
    
    // MARK: - Authentication
    @MainActor
    func fetchAccount(authToken: String? = nil) async {
        do {
            let token = (authToken == nil) ? (try await firebaseAuthService.getIDToken()) : authToken!
            let account = try await accountService.getAccount(authToken: token)
            authState = .authenticated(account)
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func deleteAccount() async {
        do {
            let authToken = try await firebaseAuthService.getIDToken()
            try await accountService.deleteAccount(authToken: authToken)
            signOut()
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func signInWithApple() async {
        isAppleAuthInProgress = true
        defer { isAppleAuthInProgress = false }
        
        triggerImpactFeedback()
        
        do {
            let credential = try await appleSignInService.singIn()
            await signIn(with: credential)
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func signInWithGoogle() async {
        isGoogleAuthInProgress = true
        defer { isGoogleAuthInProgress = false }
        
        triggerImpactFeedback()
        
        do {
            guard let clientID = firebaseAuthService.clientID,
                  let rootViewController = UIApplication.rootViewController else {
                throw AuthError.unknownError
            }
            
            googleSignInService.configure(clientID: clientID)
            
            let signInResult = try await googleSignInService.signIn(withPresenting: rootViewController)
            let user = signInResult.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.failedToSignIn(provider: .google)
            }
            
            let credential = googleSignInService.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            await signIn(with: credential)
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func signInWithTwitter() async {
        isTwitterAuthInProgress = true
        defer { isTwitterAuthInProgress = false }
        
        triggerImpactFeedback()
        
        do {
            let credential = try await twitterSignInService.signIn()
            await signIn(with: credential)
        } catch {
            setError(error)
        }
    }
    
    func signOutUserIfNeeded() {
        guard isFirstLaunch else { return }
        signOut()
    }
    
    func signOut() {
        do {
            try firebaseAuthService.signOut()
            authState = .unauthenticated
        } catch {
            setError(error)
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
        
        if account != nil {
            settings.append(Setting(type: .deleteAccount))
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
    @MainActor
    private func signIn(with credential: AuthCredential) async {
        do {
            let result = try await firebaseAuthService.signIn(with: credential)
            let authToken = try await result.user.getIDToken()
            await fetchAccount(authToken: authToken)
        } catch {
            setError(error)
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
        case deleteAccount
        
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
            case .deleteAccount:
                return "Delete Account"
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
            case .deleteAccount:
                return "person.slash.fill"
            }
        }
        
        var options: [SettingOption] {
            switch self {
            case .startScreen:
                return StartScreen.allCases.map { SettingOption(title: $0.title, imageName: $0.imageName, value: $0.rawValue) }
            case .language:
                return Language.allCases.map { SettingOption(title: $0.title, value: $0.rawValue) }
            case .currency:
                return Currency.allCases.map { SettingOption(title: $0.title, value: $0.rawValue) }
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
        
        var title: String {
            switch self {
            case .english: return "English"
            }
        }
    }
    
    enum Currency: Int, CaseIterable {
        case usd
        
        var title: String {
            switch self {
            case .usd: return "USD"
            }
        }
    }
}

struct SettingOption: Hashable {
    let title: String
    let imageName: String?
    let value: Int
    
    init(title: String, imageName: String? = nil, value: Int) {
        self.title = title
        self.imageName = imageName
        self.value = value
    }
}
