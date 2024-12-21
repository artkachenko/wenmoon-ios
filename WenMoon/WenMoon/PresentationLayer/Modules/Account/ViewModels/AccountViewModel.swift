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
    
    // MARK: - Properties
    @Published var settings: [Setting] = []
    @Published var loginState: LoginState = .signedOut
    
    @Published private(set) var isGoogleAuthInProgress = false
    @Published private(set) var isTwitterAuthInProgress = false
    
    private let googleSignInService: GoogleSignInService
    private let twitterSignInService: TwitterSignInService
    
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
        defer { isGoogleAuthInProgress = false }
        
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
            signIn(with: credential)
        }
    }
    
    func signInWithTwitter() {
        isTwitterAuthInProgress = true
        defer { isTwitterAuthInProgress = false }
        
        twitterSignInService.signIn { [weak self] credential, error in
            guard
                let self,
                let credential,
                error == nil
            else {
                self?.isTwitterAuthInProgress = false
                return
            }
            
            signIn(with: credential)
        }
    }
    
    func signOut() {
        do {
            try firebaseAuthService.signOut()
            loginState = .signedOut
        } catch {
            setErrorMessage(error)
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
            Setting(type: .language, selectedOption: getSavedSetting(of: .language)),
            Setting(type: .currency, selectedOption: getSavedSetting(of: .currency)),
            Setting(type: .privacyPolicy)
        ]
        
        if case .signedIn = loginState {
            settings.append(Setting(type: .signOut))
        }
    }
    
    func updateSetting(of type: Setting.SettingType, with value: String) {
        if let index = settings.firstIndex(where: { $0.type == type }) {
            settings[index].selectedOption = value
            setSetting(value, of: settings[index].type)
        }
    }
    
    func getSetting(of type: Setting.SettingType) -> Setting? {
        settings.first(where: { $0.type == type })
    }
    
    // MARK: - Private Methods
    private func signIn(with credential: AuthCredential) {
        firebaseAuthService.signIn(with: credential) { [weak self] authResult, error in
            if let error {
                self?.setErrorMessage(error)
            } else {
                self?.loginState = .signedIn(authResult?.user.displayName)
            }
        }
    }
    
    private func getSavedSetting(of type: Setting.SettingType) -> String? {
        try? userDefaultsManager.getObject(forKey: type.rawValue, objectType: String.self) ?? type.defaultOption?.name
    }
    
    private func setSetting(_ setting: String, of type: Setting.SettingType) {
        try? userDefaultsManager.setObject(setting, forKey: type.rawValue)
    }
}

struct Setting: Identifiable, Hashable {
    enum SettingType: String, CaseIterable {
        struct Option {
            let name: String
            let isEnabled: Bool
        }
        
        enum Language: String, CaseIterable {
            case english = "English"
            case spanish = "Spanish"
            case german = "German"
            case french = "French"
        }

        enum Currency: String, CaseIterable {
            case usd = "USD"
            case eur = "EUR"
            case gbp = "GBP"
            case jpy = "JPY"
        }
        
        case language
        case currency
        case privacyPolicy
        case signOut
        
        var title: String {
            switch self {
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
        
        var icon: String {
            switch self {
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
        
        var options: [Option] {
            switch self {
            case .language:
                return Language.allCases.map { Option(name: $0.rawValue, isEnabled: $0 == .english) }
            case .currency:
                return Currency.allCases.map { Option(name: $0.rawValue, isEnabled: $0 == .usd) }
            default:
                return []
            }
        }
        
        var defaultOption: Option? {
            switch self {
            case .language:
                return Option(name: Language.english.rawValue, isEnabled: true)
            case .currency:
                return Option(name: Currency.usd.rawValue, isEnabled: true)
            default:
                return nil
            }
        }
    }
    
    var id = UUID().uuidString
    let type: SettingType
    var selectedOption: String? = nil
}
