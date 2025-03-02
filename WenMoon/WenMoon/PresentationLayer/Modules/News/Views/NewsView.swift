//
//  NewsView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import SwiftUI

struct NewsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = NewsViewModel()
    
    @State private var selectedNews: News?
    @State private var viewDidLoad = false
    
    private var news: [News] { viewModel.news }
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            NavigationView {
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.large)
                    } else {
                        ZStack {
                            List {
                                if !news.isEmpty {
                                    ForEach(news, id: \.self) { news in
                                        makeNewsRow(news)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .animation(.easeInOut, value: news)
                            .refreshable {
                                Task {
                                    await viewModel.fetchAllNews()
                                }
                            }
                            
                            if news.isEmpty {
                                PlaceholderView(text: "No news available yet")
                            }
                        }
                    }
                }
                .navigationTitle("News")
            }
        }
        .sheet(item: $selectedNews) { news in
            if let url = news.url?.safeURL {
                SFSafariView(url: url)
            }
        }
        .task {
            guard !viewDidLoad else { return }
            await viewModel.fetchAllNews()
            viewDidLoad = true
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeNewsRow(_ news: News) -> some View {
        HStack(spacing: 16) {
            if let imageURL = news.thumbnail?.safeURL {
                AsyncImage(url: imageURL, content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                }, placeholder: {
                    ProgressView()
                })
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let title = news.title {
                    Text(title)
                        .font(.subheadline).bold()
                        .lineLimit(2)
                }
                
                if let url = news.url?.safeURL,
                   let source = viewModel.extractSource(from: url) {
                    HStack {
                        Text(source)
                        
                        Circle()
                            .frame(width: 4, height: 4)
                        
                        Text(news.date.formatted(as: .relative))
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
            }
        }
        .onTapGesture {
            selectedNews = news
        }
    }
}
