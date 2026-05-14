import SwiftUI

struct ConteudoView: View {
    let storage: StorageService
    let premiumService: PremiumService
    @Binding var showPaywall: Bool
    @State private var selectedFilter: ContentFilter = .all
    @State private var showMiniPlayer: Bool = false
    @State private var playingItem: ContentItem?

    private var isPremium: Bool { premiumService.isPremium }

    nonisolated private enum ContentFilter: String, CaseIterable, Sendable {
        case all = "Tudo"
        case audio = "Áudio"
        case video = "Vídeo"
        case article = "Artigos"
    }

    private var filteredFeed: [ContentItem] {
        switch selectedFilter {
        case .all: return ContentItem.mockFeed
        case .audio: return ContentItem.mockFeed.filter { $0.type == .audio }
        case .video: return ContentItem.mockFeed.filter { $0.type == .video }
        case .article: return ContentItem.mockFeed.filter { $0.type == .article }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    filterChips
                    creatorFeed
                    clubeSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, showMiniPlayer ? 100 : 32)
            }
            .scrollIndicators(.hidden)

            if showMiniPlayer, let item = playingItem {
                miniPlayerBar(item: item)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Conteúdo")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ContentFilter.allCases, id: \.rawValue) { filter in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(AppTheme.sansFont(.subheadline, weight: selectedFilter == filter ? .semibold : .regular))
                            .foregroundStyle(selectedFilter == filter ? .white : AppTheme.charcoal)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(selectedFilter == filter ? AppTheme.rose : AppTheme.creamDark.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private var creatorFeed: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.caption)
                    .foregroundStyle(AppTheme.rose)
                Text("Cantinho da Criadora")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            if filteredFeed.isEmpty {
                emptyFeedState
            } else {
                ForEach(filteredFeed) { item in
                    contentCard(item)
                }
            }
        }
    }

    private var emptyFeedState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(AppTheme.charcoalLight.opacity(0.4))
            Text("Nenhum conteúdo nesta categoria")
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoalLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func contentCard(_ item: ContentItem) -> some View {
        Button {
            handleContentTap(item)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(cardColor(for: item.type).opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: item.icon)
                        .font(.title3)
                        .foregroundStyle(cardColor(for: item.type))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.title)
                            .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.charcoal)
                            .lineLimit(1)
                        if item.isPremium && !isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.rose)
                        }
                    }
                    Text(item.subtitle)
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                        .lineLimit(1)
                }

                Spacer()

                if let duration = item.duration {
                    Text(duration)
                        .font(AppTheme.sansFont(.caption2, weight: .medium))
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            }
            .warmCard(padding: 14)
        }
        .buttonStyle(ContentCardButtonStyle())
    }

    private var clubeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.sageDark)
                Text("Perguntar ao Clube")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Spacer()
                if isPremium {
                    Text("Premium")
                        .font(AppTheme.sansFont(.caption2, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.sage)
                        .clipShape(.rect(cornerRadius: 6))
                }
            }

            if isPremium {
                premiumThreads
            } else {
                clubePaywallEntry
            }
        }
    }

    private var premiumThreads: some View {
        ForEach(ContentItem.mockThreads) { item in
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.sageLight.opacity(0.4))
                        .frame(width: 44, height: 44)
                    Image(systemName: item.icon)
                        .font(.body)
                        .foregroundStyle(AppTheme.sage)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(AppTheme.sansFont(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.charcoal)
                        .lineLimit(1)
                    Text(item.subtitle)
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.4))
            }
            .warmCard(padding: 14)
        }
    }

    private var clubePaywallEntry: some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseLight.opacity(0.5))
                        .frame(width: 52, height: 52)
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.rose)
                }

                Text("Conteúdo exclusivo para assinantes")
                    .font(AppTheme.sansFont(.subheadline, weight: .medium))
                    .foregroundStyle(AppTheme.charcoal)

                Text("Acesse conversas privadas, perguntas ao grupo e mais")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .multilineTextAlignment(.center)

                Text("Desbloquear")
                    .font(AppTheme.sansFont(.footnote, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppTheme.rose)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [AppTheme.roseLight.opacity(0.2), AppTheme.cream],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppTheme.rose.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func miniPlayerBar(item: ContentItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(cardColor(for: item.type).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: item.type == .audio ? "waveform" : "play.fill")
                    .font(.caption)
                    .foregroundStyle(cardColor(for: item.type))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppTheme.sansFont(.footnote, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                    .lineLimit(1)
                Text("Reproduzindo...")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    showMiniPlayer = false
                    playingItem = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.charcoalLight)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: AppTheme.cardShadow, radius: 8, y: -2)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func cardColor(for type: ContentItem.ContentType) -> Color {
        switch type {
        case .audio: return AppTheme.sage
        case .video: return AppTheme.roseDark
        case .article: return AppTheme.sageDark
        case .thread: return AppTheme.sage
        }
    }

    private func handleContentTap(_ item: ContentItem) {
        if item.isPremium && !isPremium {
            showPaywall = true
            return
        }
        AnalyticsService.shared.track(.contentOpened, params: [
            "content_id": item.id.uuidString,
            "type": item.type.rawValue
        ])
        // TODO: share_tapped — ligar aqui quando botão de compartilhar for adicionado ao card
        if item.type == .audio || item.type == .video {
            withAnimation(.spring(duration: 0.3)) {
                playingItem = item
                showMiniPlayer = true
            }
        }
    }
}

private struct ContentCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
