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
    var appleSignInService: AppleSignInServiceMock!
    var googleSignInService: GoogleSignInServiceMock!
    var twitterSignInService: TwitterSignInServiceMock!
    var accountService: AccountServiceMock!
    var appLaunchProvider: AppLaunchProviderMock!
    var userDefaultsManager: UserDefaultsManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        firebaseAuthService = FirebaseAuthServiceMock()
        appleSignInService = AppleSignInServiceMock()
        googleSignInService = GoogleSignInServiceMock()
        twitterSignInService = TwitterSignInServiceMock()
        accountService = AccountServiceMock()
        appLaunchProvider = AppLaunchProviderMock()
        userDefaultsManager = UserDefaultsManagerMock()
        
        viewModel = AccountViewModel(
            firebaseAuthService: firebaseAuthService,
            appleSignInService: appleSignInService,
            googleSignInService: googleSignInService,
            twitterSignInService: twitterSignInService,
            accountService: accountService,
            appLaunchProvider: appLaunchProvider,
            userDefaultsManager: userDefaultsManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        firebaseAuthService = nil
        appleSignInService = nil
        googleSignInService = nil
        twitterSignInService = nil
        accountService = nil
        appLaunchProvider = nil
        userDefaultsManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Create/Fetch Account
    func testFetchAccount_success_withAuthToken() async {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        accountService.getAccountResult = .success(account)
        
        // Action
        await viewModel.fetchAccount(authToken: "test-auth-token")
        
        // Assertions
        XCTAssertEqual(viewModel.account, account)
    }
    
    func testFetchAccount_success_withoutAuthToken() async {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        accountService.getAccountResult = .success(account)
        firebaseAuthService.idTokenResult = .success("test-id-token")
        
        // Action
        await viewModel.fetchAccount()
        
        // Assertions
        XCTAssertEqual(viewModel.account, account)
    }
    
    func testFetchAccount_failedToFetchAccount() async {
        // Setup
        let error: AuthError = .failedToFetchAccount
        accountService.getAccountResult = .failure(error)
        
        // Action
        await viewModel.fetchAccount(authToken: "test-auth-token")
        
        // Assertions
        XCTAssertNil(viewModel.account)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchAccount_failedToFetchFirebaseToken() async {
        // Setup
        let error: AuthError = .failedToFetchFirebaseToken
        firebaseAuthService.idTokenResult = .failure(error)
        
        // Action
        await viewModel.fetchAccount()
        
        // Assertions
        XCTAssertNil(viewModel.account)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Delete Account
    func testDeleteAccount_success() async {
        // Setup
        viewModel.authState = .authenticated(AccountFactoryMock.makeAccount())
        accountService.deleteAccountResult = .success(())
        
        firebaseAuthService.idTokenResult = .success("test-id-token")
        firebaseAuthService.signOutResult = .success(())
        
        // Action
        await viewModel.deleteAccount()
        
        // Assertions
        XCTAssertNil(viewModel.account)
    }
    
    func testDeleteAccount_failedToDeleteAccount() async {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        viewModel.authState = .authenticated(account)
        
        firebaseAuthService.idTokenResult = .success("test-id-token")
        
        let error: AuthError = .failedToDeleteAccount
        accountService.deleteAccountResult = .failure(error)
        
        // Action
        await viewModel.deleteAccount()
        
        // Assertions
        XCTAssertNotNil(viewModel.account)
        XCTAssertEqual(viewModel.account, account)
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testDeleteAccount_failedToFetchFirebaseToken() async {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        viewModel.authState = .authenticated(account)
        accountService.deleteAccountResult = .success(())
        
        let error: AuthError = .failedToFetchFirebaseToken
        firebaseAuthService.idTokenResult = .failure(error)
        
        // Action
        await viewModel.deleteAccount()
        
        // Assertions
        XCTAssertNotNil(viewModel.account)
        XCTAssertEqual(viewModel.account, account)
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Sign Out
    func testSignOutUserIfNeeded_isFirstLaunch() {
        // Setup
        viewModel.authState = .authenticated(AccountFactoryMock.makeAccount())
        firebaseAuthService.signOutResult = .success(())
        
        // Action
        viewModel.signOutUserIfNeeded()
        
        // Assertions
        XCTAssertNil(viewModel.account)
    }
    
    func testSignOutUserIfNeeded_isNotFirstLaunch() {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        viewModel.authState = .authenticated(account)
        appLaunchProvider.isFirstLaunch = false
        
        // Action
        viewModel.signOutUserIfNeeded()
        
        // Assertions
        XCTAssertEqual(viewModel.account, account)
    }
    
    func testSignOut_success() {
        // Setup
        viewModel.authState = .authenticated(AccountFactoryMock.makeAccount())
        firebaseAuthService.signOutResult = .success(())
        
        // Action
        viewModel.signOut()
        
        // Assertions
        XCTAssertNil(viewModel.account)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignOut_failure() {
        // Setup
        let account = AccountFactoryMock.makeAccount()
        viewModel.authState = .authenticated(account)
        
        let error: AuthError = .failedToSignOut
        firebaseAuthService.signOutResult = .failure(error)
        
        // Action
        viewModel.signOut()
        
        // Assertions
        XCTAssertEqual(viewModel.account, account)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Settings
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
