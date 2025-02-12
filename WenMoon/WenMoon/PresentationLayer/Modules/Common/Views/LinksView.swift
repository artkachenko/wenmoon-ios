//
//  LinksView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.02.25.
//

import SwiftUI

// MARK: - LinksView
struct LinksView: View {
    let links: CoinDetails.Links
    
    @Environment(\.openURL) private var openURLAction
    
    @State private var selectedLinks: [URL] = []
    @State private var showingActionSheet = false
    
    var body: some View {
        ScrollView {
            FlowLayout(spacing: 10) {
                ForEach(Array(generateLinkButtons().enumerated()), id: \.offset) { _, view in
                    view
                }
            }
        }
        .confirmationDialog("Select a Link", isPresented: $showingActionSheet, titleVisibility: .visible) {
            ForEach(selectedLinks, id: \.self) { url in
                Button {
                    openURLAction(url)
                } label: {
                    Text(extractDomain(from: url))
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func generateLinkButtons() -> [AnyView] {
        var buttons: [AnyView] = []
        
        appendMultiLinkButton(
            to: &buttons,
            title: "Website",
            links: validLinks(from: links.homepage),
            showFullURL: false,
            systemImageName: "globe"
        )
        
        if let whitepaperURL = validURL(links.whitepaper) {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: "Whitepaper",
                        url: whitepaperURL,
                        systemImageName: "doc"
                    )
                )
            )
        }
        
        if let twitter = links.twitterScreenName, !twitter.isEmpty,
           let twitterURL = URL(string: "https://twitter.com/\(twitter)") {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: "X",
                        url: twitterURL,
                        imageName: "x.logo"
                    )
                )
            )
        }
        
        if let subredditURL = validURL(links.subredditUrl),
           subredditURL.absoluteString != "https://www.reddit.com" {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: "Reddit",
                        url: subredditURL,
                        imageName: "reddit.logo"
                    )
                )
            )
        }
        
        if let telegram = links.telegramChannelIdentifier, !telegram.isEmpty,
           let telegramURL = URL(string: "https://t.me/\(telegram)") {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: "Telegram",
                        url: telegramURL,
                        imageName: "telegram.logo"
                    )
                )
            )
        }
        
        appendMultiLinkButton(
            to: &buttons,
            title: "Communication",
            links: validLinks(from: links.communication),
            showFullURL: false,
            systemImageName: "message.fill"
        )
        
        appendMultiLinkButton(
            to: &buttons,
            title: "Explorer",
            links: validLinks(from: links.blockchainSite),
            showFullURL: false,
            systemImageName: "link"
        )
        
        let githubLinks = validLinks(from: links.reposUrl.github)
        if githubLinks.count == 1, let url = githubLinks.first {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: "GitHub",
                        url: url,
                        imageName: "github.logo"
                    )
                )
            )
        } else if !githubLinks.isEmpty {
            buttons.append(
                AnyView(
                    MultiLinkButtonView(
                        title: "GitHub",
                        links: githubLinks,
                        imageName: "github.logo",
                        showFullURL: true,
                        showingActionSheet: $showingActionSheet,
                        selectedLinks: $selectedLinks
                    )
                )
            )
        }
        
        return buttons
    }
    
    private func appendMultiLinkButton(
        to buttons: inout [AnyView],
        title: String,
        links: [URL],
        showFullURL: Bool,
        imageName: String? = nil,
        systemImageName: String? = nil
    ) {
        guard !links.isEmpty else { return }
        if links.count == 1, let url = links.first {
            buttons.append(
                AnyView(
                    LinkButtonView(
                        title: title,
                        url: url,
                        imageName: imageName,
                        systemImageName: systemImageName
                    )
                )
            )
        } else {
            buttons.append(
                AnyView(
                    MultiLinkButtonView(
                        title: title,
                        links: links,
                        imageName: imageName,
                        systemImageName: systemImageName,
                        showFullURL: showFullURL,
                        showingActionSheet: $showingActionSheet,
                        selectedLinks: $selectedLinks
                    )
                )
            )
        }
    }
    
    private func validURL(_ urlString: String?) -> URL? {
        guard
            let urlString = urlString,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else {
            return nil
        }
        return url
    }
    
    private func validLinks(from urls: [String]?) -> [URL] {
        urls?.compactMap { validURL($0) } ?? []
    }
    
    private func extractDomain(from url: URL) -> String {
        let absoluteString = url.absoluteString
        if absoluteString.contains("github") {
            return absoluteString.replacingOccurrences(of: "https://", with: "")
        } else {
            let domain = url.host ?? absoluteString
            return domain.replacingOccurrences(of: "www.", with: "")
        }
    }
}

// MARK: - LinkButtonView
struct LinkButtonView: View {
    let title: String
    let url: URL
    let imageName: String?
    let systemImageName: String?
    
    @Environment(\.openURL) private var openURLAction
    
    init(
        title: String,
        url: URL,
        imageName: String? = nil,
        systemImageName: String? = nil
    ) {
        self.title = title
        self.url = url
        self.imageName = imageName
        self.systemImageName = systemImageName
    }
    
    var body: some View {
        Button {
            openURLAction(url)
        } label: {
            LinkButtonContent(
                title: title,
                imageName: imageName,
                systemImageName: systemImageName
            )
        }
    }
}

// MARK: - MultiLinkButtonView
struct MultiLinkButtonView: View {
    let title: String
    let links: [URL]
    let imageName: String?
    let systemImageName: String?
    let showFullURL: Bool
    
    @Binding var showingActionSheet: Bool
    @Binding var selectedLinks: [URL]
    
    init(
        title: String,
        links: [URL],
        imageName: String? = nil,
        systemImageName: String? = nil,
        showFullURL: Bool = false,
        showingActionSheet: Binding<Bool>,
        selectedLinks: Binding<[URL]>
    ) {
        self.title = title
        self.links = links
        self.imageName = imageName
        self.systemImageName = systemImageName
        self.showFullURL = showFullURL
        self._showingActionSheet = showingActionSheet
        self._selectedLinks = selectedLinks
    }
    
    var body: some View {
        Button {
            selectedLinks = links
            showingActionSheet = true
        } label: {
            LinkButtonContent(
                title: title,
                imageName: imageName,
                systemImageName: systemImageName
            )
        }
    }
}

// MARK: - LinkButtonContent
struct LinkButtonContent: View {
    let title: String
    let imageName: String?
    let systemImageName: String?
    
    var body: some View {
        HStack(spacing: 4) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            } else if let systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(18)
        .fixedSize()
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            if currentX + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                currentX = 0
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
