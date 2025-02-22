//
//  AccountViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
import FirebaseAuth
@testable import WenMoon

class AccountViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: AccountViewModel!
    
    var firebaseAuthService: FirebaseAuthServiceMock!
    var googleSignInService: GoogleSignInServiceMock!
    var twitterSignInService: TwitterSignInServiceMock!
    var authStateManager: AuthStateManagerMock!
    var appLaunchProvider: AppLaunchProviderMock!
    var userDefaultsManager: UserDefaultsManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        firebaseAuthService = FirebaseAuthServiceMock()
        googleSignInService = GoogleSignInServiceMock()
        twitterSignInService = TwitterSignInServiceMock()
        authStateManager = AuthStateManagerMock()
        appLaunchProvider = AppLaunchProviderMock()
        userDefaultsManager = UserDefaultsManagerMock()
        
        viewModel = AccountViewModel(
            firebaseAuthService: firebaseAuthService,
            googleSignInService: googleSignInService,
            twitterSignInService: twitterSignInService,
            authStateManager: authStateManager,
            appLaunchProvider: appLaunchProvider,
            userDefaultsManager: userDefaultsManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        firebaseAuthService = nil
        googleSignInService = nil
        twitterSignInService = nil
        authStateManager = nil
        appLaunchProvider = nil
        userDefaultsManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchAccount_success() async {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        authStateManager.fetchAccountResult = .success(account)
        
        // Action
        await viewModel.fetchAccount()
        
        // Assertions
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.account, account)
    }
    
    func testFetchAccount_failure() async {
        // Setup
        let error: AuthError = .failedToFetchFirebaseToken
        authStateManager.fetchAccountResult = .failure(error)
        
        // Action
        await viewModel.fetchAccount()
        
        // Assertions
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.account)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testSignOutUserIfNeeded_isFirstLaunch() {
        // Setup
        authStateManager.authState = .authenticated(AccountFactoryMock.makeAccount())
        authStateManager.signOutResult = .success(())
        
        // Action
        viewModel.signOutUserIfNeeded()
        
        // Assertions
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.account)
    }
    
    func testSignOutUserIfNeeded_isNotFirstLaunch() {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        authStateManager.authState = .authenticated(account)
        appLaunchProvider.isFirstLaunch = false
        
        // Action
        viewModel.signOutUserIfNeeded()
        
        // Assertions
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.account, account)
    }
    
    func testSignOut_success() {
        // Setup
        authStateManager.authState = .authenticated(AccountFactoryMock.makeAccount())
        authStateManager.signOutResult = .success(())
        
        // Action
        viewModel.signOut()
        
        // Assertions
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.account)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignOut_failure() {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        authStateManager.authState = .authenticated(account)
        
        let error: AuthError = .failedToSignOut
        authStateManager.signOutResult = .failure(error)
        
        // Action
        viewModel.signOut()
        
        // Assertions
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.account, account)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchSettings() {
        // Setup
        let selectedStartScreenOption = 0
        let selectedLanguageOption = 1
        let selectedCurrencyOption = 2
        userDefaultsManager.getObjectReturnValue = [
            .setting(ofType: .startScreen): selectedStartScreenOption,
            .setting(ofType: .language): selectedLanguageOption,
            .setting(ofType: .currency): selectedCurrencyOption
        ]
        let expectedSettings: [Setting] = [
            Setting(type: .startScreen, selectedOption: selectedStartScreenOption),
            Setting(type: .language, selectedOption: selectedLanguageOption),
            Setting(type: .currency, selectedOption: selectedCurrencyOption),
            Setting(type: .privacyPolicy)
        ]
        
        // Action
        viewModel.fetchSettings()
        
        // Assertions
        XCTAssertEqual(viewModel.settings.count, expectedSettings.count)
        for (index, setting) in viewModel.settings.enumerated() {
            XCTAssertEqual(setting.type, expectedSettings[index].type)
            XCTAssertEqual(setting.selectedOption, expectedSettings[index].selectedOption)
        }
    }
    
    func testUpdateSetting() {
        // Setup
        let languageSetting = Setting(type: .language, selectedOption: 0)
        viewModel.settings = [languageSetting]
        
        // Action
        let newLanguageSettingValue = 1
        viewModel.updateSetting(of: .language, with: newLanguageSettingValue)
        
        // Assertions
        let updatedSetting = viewModel.getSetting(of: .language)!
        XCTAssertEqual(updatedSetting.selectedOption, newLanguageSettingValue)
        XCTAssertTrue(userDefaultsManager.setObjectCalled)
        XCTAssertEqual(userDefaultsManager.setObjectValue[.setting(ofType: languageSetting.type)] as! Int, newLanguageSettingValue)
    }
    
    func testGetSetting() {
        // Setup
        let startScreenSetting = Setting(type: .startScreen, selectedOption: 0)
        let languageSetting = Setting(type: .language, selectedOption: 1)
        let currencySetting = Setting(type: .currency, selectedOption: 2)
        viewModel.settings = [startScreenSetting, languageSetting, currencySetting]
        
        // Assertions
        let fetchedStartScreenSetting = viewModel.getSetting(of: .startScreen)
        XCTAssertEqual(fetchedStartScreenSetting, startScreenSetting)
        
        let fetchedLanguageSetting = viewModel.getSetting(of: .language)
        XCTAssertEqual(fetchedLanguageSetting, languageSetting)
        
        let fetchedCurrencySetting = viewModel.getSetting(of: .currency)
        XCTAssertEqual(fetchedCurrencySetting, currencySetting)
        
        let nonExistentSetting = viewModel.getSetting(of: .privacyPolicy)
        XCTAssertNil(nonExistentSetting)
    }
}
