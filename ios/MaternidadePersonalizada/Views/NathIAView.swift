import SwiftUI

struct NathIAView: View {
    let premiumService: PremiumService
    @Binding var showPaywall: Bool
    @State private var viewModel: NathIAViewModel
    @FocusState private var isInputFocused: Bool

    private let nathAvatarURL = "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/it21s4iqsrjbsnpr6nn3c"

    init(premiumService: PremiumService, showPaywall: Binding<Bool>) {
        self.premiumService = premiumService
        self._showPaywall = showPaywall
        self._viewModel = State(initialValue: NathIAViewModel(premiumService: premiumService))
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            nathProfileBanner
                                .padding(.top, 8)

                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    nathAvatarURL: nathAvatarURL
                                )
                                .id(message.id)
                            }

                            if viewModel.isLoading {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            if viewModel.isLoading {
                                proxy.scrollTo("typing", anchor: .bottom)
                            } else if let last = viewModel.messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isLoading) { _, newValue in
                        if newValue {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }

                inputSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: nathAvatarURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            AppTheme.roseLight
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())

                    Text("NathIA")
                        .font(AppTheme.serifFont(.headline, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        viewModel.clearChat()
                    } label: {
                        Label("Limpar conversa", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            }
        }
        .onChange(of: premiumService.isPremium) { _, _ in
            viewModel.refreshGating()
        }
        .onChange(of: viewModel.showPaywall) { _, newValue in
            if newValue {
                showPaywall = true
                viewModel.showPaywall = false
            }
        }
    }

    // MARK: - Profile Banner

    private var nathProfileBanner: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: nathAvatarURL)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    AppTheme.roseLight
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(AppTheme.rose.opacity(0.3), lineWidth: 2)
            }

            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("NathIA")
                        .font(AppTheme.serifFont(.body, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(AppTheme.rose)
                }
                Text("Sua companheira virtual de maternidade")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            if !premiumService.isPremium {
                gatingIndicator
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var gatingIndicator: some View {
        switch viewModel.gatingState {
        case .unlocked:
            EmptyView()

        case .freeZone(let remaining):
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < viewModel.userMessageCount ? AppTheme.rose : AppTheme.rose.opacity(0.2))
                        .frame(width: 20, height: 4)
                }
            }
            .overlay(alignment: .trailing) {
                Text("\(remaining) restante\(remaining == 1 ? "" : "s")")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.7))
                    .offset(x: 74)
            }
            .padding(.trailing, 74)

        case .softGate:
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.rose)
                Text("A NathIA adorou conversar com você!")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.roseLight.opacity(0.35))
            .clipShape(Capsule())

        case .hardGate:
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.rose)
                Text("Mensagens gratuitas esgotadas")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppTheme.roseLight.opacity(0.35))
            .clipShape(Capsule())
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 0) {
            gatingBanner

            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                TextField(
                    inputPlaceholder,
                    text: $viewModel.inputText,
                    axis: .vertical
                )
                .font(AppTheme.sansFont(.body))
                .lineLimit(1...5)
                .focused($isInputFocused)
                .disabled(!viewModel.gatingState.isInputEnabled)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.cardBackground)
                .clipShape(.rect(cornerRadius: 22))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            viewModel.gatingState.isInputEnabled ? AppTheme.creamDark : AppTheme.rose.opacity(0.3),
                            lineWidth: 1
                        )
                }

                sendOrUnlockButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .animation(.spring(duration: 0.35), value: viewModel.gatingState)
    }

    private var inputPlaceholder: String {
        switch viewModel.gatingState {
        case .hardGate: return "Desbloqueie para continuar..."
        case .softGate: return "Última mensagem gratuita..."
        default: return "Pergunte à NathIA..."
        }
    }

    @ViewBuilder
    private var sendOrUnlockButton: some View {
        if case .hardGate = viewModel.gatingState {
            Button {
                showPaywall = true
                AnalyticsService.shared.track(.paywallViewed, params: ["context": "nathia_unlock_button"])
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "lock.open.fill")
                        .font(.caption.weight(.bold))
                    Text("Desbloquear")
                        .font(AppTheme.sansFont(.caption, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.rose)
                .clipShape(Capsule())
                .shadow(color: AppTheme.rose.opacity(0.35), radius: 6, y: 3)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.gatingState)
        } else {
            Button {
                viewModel.sendMessage()
                isInputFocused = false
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(canSend ? AppTheme.rose : AppTheme.creamDark)
            }
            .disabled(!canSend || viewModel.isLoading)
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.messages.count)
        }
    }

    // MARK: - Gating Banner

    @ViewBuilder
    private var gatingBanner: some View {
        switch viewModel.gatingState {
        case .freeZone(let remaining) where remaining <= 1:
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(AppTheme.rose)
                Text(remaining == 1 ? "1 mensagem gratuita restante" : "Última mensagem gratuita!")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoal)

                Spacer()

                Button {
                    showPaywall = true
                    AnalyticsService.shared.track(.paywallViewed, params: ["context": "nathia_free_banner"])
                } label: {
                    Text("Seja Premium")
                        .font(AppTheme.sansFont(.caption, weight: .semibold))
                        .foregroundStyle(AppTheme.rose)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.rose.opacity(0.08))
            .transition(.move(edge: .top).combined(with: .opacity))

        case .softGate:
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(AppTheme.rose)
                    .font(.caption)
                Text("A NathIA adorou conversar com você!")
                    .font(AppTheme.sansFont(.caption))

                Spacer()

                Button {
                    showPaywall = true
                    AnalyticsService.shared.track(.paywallViewed, params: ["context": "nathia_soft_gate"])
                } label: {
                    Text("Continuar →")
                        .font(AppTheme.sansFont(.caption, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.rose, AppTheme.roseDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppTheme.rose.opacity(0.12))
            .transition(.move(edge: .top).combined(with: .opacity))

        case .hardGate:
            Button {
                showPaywall = true
                AnalyticsService.shared.track(.paywallViewed, params: ["context": "nathia_hard_gate_banner"])
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseLight)
                            .frame(width: 36, height: 36)
                        Image(systemName: "crown.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.rose)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Continue com a NathIA")
                            .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.charcoal)
                        Text("Desbloqueie conversas ilimitadas")
                            .font(AppTheme.sansFont(.caption))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.rose)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [AppTheme.roseLight.opacity(0.5), AppTheme.roseLight.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .bottom).combined(with: .opacity))

        default:
            EmptyView()
        }
    }

    private var canSend: Bool {
        !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isLoading
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage
    let nathAvatarURL: String

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 48) }

            if !isUser {
                AsyncImage(url: URL(string: nathAvatarURL)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        AppTheme.roseLight
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(AppTheme.sansFont(.body))
                    .foregroundStyle(isUser ? .white : AppTheme.charcoal)
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isUser
                            ? AnyShapeStyle(LinearGradient(colors: [AppTheme.rose, AppTheme.roseDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(AppTheme.cardBackground)
                    )
                    .clipShape(.rect(cornerRadii: .init(
                        topLeading: 18,
                        bottomLeading: isUser ? 18 : 4,
                        bottomTrailing: isUser ? 4 : 18,
                        topTrailing: 18
                    )))
                    .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)

                Text(message.date.formatted(.dateTime.hour().minute()))
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.6))
            }

            if !isUser { Spacer(minLength: 48) }
        }
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var dotIndex: Int = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(AppTheme.roseLight)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.rose)
                }

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(AppTheme.charcoalLight.opacity(0.4))
                        .frame(width: 7, height: 7)
                        .scaleEffect(dotIndex == i ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: dotIndex)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadii: .init(topLeading: 18, bottomLeading: 4, bottomTrailing: 18, topTrailing: 18)))
            .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 1)

            Spacer(minLength: 48)
        }
        .onAppear { dotIndex = 2 }
    }
}
