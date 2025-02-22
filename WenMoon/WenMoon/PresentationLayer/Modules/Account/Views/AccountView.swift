//
//  AccountView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import SwiftUI

struct AccountView: View {
    // MARK: - Properties
    @EnvironmentObject private var viewModel: AccountViewModel
    
    @State private var selectedSetting: Setting!
    @State private var showDeleteAccountConfirmation = false
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            VStack(spacing: 16) {
                makeAuthView()
                
                List {
                    ForEach(viewModel.settings) { setting in
                        makeSettingsRow(setting)
                    }
                }
                .listStyle(.plain)
                .scrollBounceBehavior(.basedOnSize)
                
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(viewModel.communityLinks, id: \.self) { link in
                        if let url = link.url {
                            LinkButtonView(url: url, imageName: link.imageName)
                        }
                    }
                }
                
                Text("App Version \(Constants.appVersion)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
        }
        .sheet(item: $selectedSetting, onDismiss: {
            selectedSetting = nil
        }) { setting in
            SelectionView(
                selectedOption: setupSettingsBinding(setting),
                title: setting.type.title,
                options: setting.type.options
            )
            .presentationDetents([.fraction(0.45)])
            .presentationCornerRadius(36)
        }
        .alert(isPresented: $showDeleteAccountConfirmation) {
            Alert(
                title: Text("Delete Account?"),
                message: Text("This action is permanent and cannot be undone. All your synced data, including your watchlist, transactions, and price alerts, will be erased."),
                primaryButton: .destructive(Text("Delete Account")) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .onChange(of: viewModel.account) {
            viewModel.fetchSettings()
        }
        .onAppear {
            viewModel.fetchSettings()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeAuthView() -> some View {
        VStack(spacing: 16) {
            Image("moon")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            if let account = viewModel.account {
                HStack(spacing: 16) {
                    Text(account.username)
                        .font(.headline)
                    
                    Button(action: {
                        viewModel.signOut()
                        viewModel.triggerImpactFeedback()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.leading, 20)
            } else {
                Text("Sign into your account")
                    .font(.headline)
                
                Text("Get customized price signals, watchlist sync and more")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    }) {
                        ZStack {
                            if viewModel.isGoogleAuthInProgress {
                                ProgressView()
                            } else {
                                Image("google.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    Button(action: {
                        Task {
                            await viewModel.signInWithTwitter()
                        }
                    }) {
                        ZStack {
                            if viewModel.isTwitterAuthInProgress {
                                ProgressView()
                            } else {
                                Image("x.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private func makeSettingsRow(_ setting: Setting) -> some View {
        let settingType = setting.type
        HStack(spacing: 12) {
            Image(systemName: settingType.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Text(settingType.title)
                .font(.body)
            
            Spacer()
            
            if let selectedOption = setting.selectedOption {
                let selectedOptionTitle = viewModel.getSettingOptionTitle(for: settingType, with: selectedOption)
                Text(selectedOptionTitle)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(setting.type == .deleteAccount ? .wmRed : .gray)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if settingType == .deleteAccount {
                showDeleteAccountConfirmation = true
                viewModel.triggerImpactFeedback()
            } else {
                selectedSetting = setting
            }
        }
        .disabled(settingType == .privacyPolicy)
        .foregroundColor(settingType == .deleteAccount ? .wmRed : .primary)
    }
    
    // MARK: - Helper Methods
    private func setupSettingsBinding(_ setting: Setting) -> Binding<Int> {
        Binding(
            get: {
                viewModel.getSetting(of: setting.type)?.selectedOption ?? .zero
            },
            set: { newValue in
                viewModel.updateSetting(of: setting.type, with: newValue)
            }
        )
    }
}
