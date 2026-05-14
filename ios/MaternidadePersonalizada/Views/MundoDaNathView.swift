import SwiftUI

struct MundoDaNathView: View {
    let storage: StorageService
    @State private var viewModel = MundoDaNathViewModel()
    @State private var showComposer: Bool = false

    private let nathAvatarURL = "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/1ewa5475ljztisu2zkho4"

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 0) {
                    nathHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    desabafoPrompt
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    if !viewModel.desabafos.isEmpty {
                        desabafosSection
                    }

                    ForEach(viewModel.posts) { post in
                        PostCardView(
                            post: post,
                            avatarURL: nathAvatarURL,
                            userName: storage.profile.userName,
                            onLike: { viewModel.toggleLike(post.id) },
                            onComment: { text in
                                let name = storage.profile.userName.isEmpty ? "Mamãe" : storage.profile.userName
                                viewModel.addComment(to: post.id, authorName: name, text: text)
                            }
                        )
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mundo da Nath")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
        .sheet(isPresented: $showComposer) {
            DesabafoComposerView(
                userName: storage.profile.userName,
                onSubmit: { text, tags in
                    let name = storage.profile.userName.isEmpty ? "Mamãe Valente" : storage.profile.userName
                    viewModel.addDesabafo(text: text, tags: tags, authorName: name)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var desabafoPrompt: some View {
        Button {
            showComposer = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppTheme.roseLight)
                    .frame(width: 36, height: 36)
                    .overlay {
                        let name = storage.profile.userName.isEmpty ? "M" : String(storage.profile.userName.prefix(1)).uppercased()
                        Text(name)
                            .font(AppTheme.sansFont(.caption, weight: .bold))
                            .foregroundStyle(AppTheme.roseDark)
                    }

                Text("Precisa desabafar? Estamos aqui 💛")
                    .font(AppTheme.sansFont(.subheadline))
                    .foregroundStyle(AppTheme.charcoalLight)

                Spacer()

                Image(systemName: "square.and.pencil")
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.rose)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(AppTheme.creamDark, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var desabafosSection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.rose)
                    Text("Desabafos da comunidade")
                        .font(AppTheme.sansFont(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.charcoalLight)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            ForEach(viewModel.desabafos) { desabafo in
                DesabafoCardView(
                    desabafo: desabafo,
                    onLike: { viewModel.toggleDesabafoLike(desabafo.id) },
                    onComment: { text in
                        let name = storage.profile.userName.isEmpty ? "Mamãe" : storage.profile.userName
                        viewModel.addDesabafoComment(to: desabafo.id, authorName: name, text: text)
                    }
                )
            }

            Divider()
                .foregroundStyle(AppTheme.creamDark)
        }
    }

    private var nathHeader: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: nathAvatarURL)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    AppTheme.roseLight
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Nath")
                        .font(AppTheme.serifFont(.title3, weight: .bold))
                        .foregroundStyle(AppTheme.charcoal)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.rose)
                }
                Text("Mãe, criadora de conteúdo & amante de café ☕")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 2)
    }
}

private struct PostCardView: View {
    let post: NathPost
    let avatarURL: String
    let userName: String
    let onLike: () -> Void
    let onComment: (String) -> Void
    @State private var showComments: Bool = false
    @State private var commentText: String = ""
    @State private var likeScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .foregroundStyle(AppTheme.creamDark)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: avatarURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            AppTheme.roseLight
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text("Nath")
                                .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                                .foregroundStyle(AppTheme.charcoal)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.rose)
                        }
                        Text(post.date.timeAgoDisplay())
                            .font(AppTheme.sansFont(.caption2))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }

                    Spacer()
                }

                if let imageURL = post.imageURL, let url = URL(string: imageURL) {
                    Color(AppTheme.creamDark)
                        .frame(height: 280)
                        .overlay {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(AppTheme.charcoalLight.opacity(0.3))
                                } else {
                                    ProgressView()
                                        .tint(AppTheme.rose)
                                }
                            }
                            .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 14))
                }

                Text(post.caption)
                    .font(AppTheme.sansFont(.body))
                    .foregroundStyle(AppTheme.charcoal)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 20) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            likeScale = 1.3
                            onLike()
                        }
                        withAnimation(.spring(duration: 0.3).delay(0.15)) {
                            likeScale = 1.0
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .font(.body)
                                .foregroundStyle(post.isLiked ? AppTheme.rose : AppTheme.charcoalLight)
                                .scaleEffect(likeScale)
                            Text("\(post.likesCount)")
                                .font(AppTheme.sansFont(.caption, weight: .medium))
                                .foregroundStyle(AppTheme.charcoalLight)
                        }
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: post.isLiked)

                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showComments.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.body)
                                .foregroundStyle(AppTheme.charcoalLight)
                            Text("\(post.comments.count)")
                                .font(AppTheme.sansFont(.caption, weight: .medium))
                                .foregroundStyle(AppTheme.charcoalLight)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                if showComments {
                    commentsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if post.comments.isEmpty {
                Text("Nenhum comentário ainda. Seja a primeira! 💬")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .padding(.vertical, 4)
            } else {
                ForEach(post.comments) { comment in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(AppTheme.sageLight)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Text(String(comment.authorName.prefix(1)).uppercased())
                                    .font(AppTheme.sansFont(.caption2, weight: .bold))
                                    .foregroundStyle(AppTheme.sageDark)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(comment.authorName)
                                    .font(AppTheme.sansFont(.caption, weight: .semibold))
                                    .foregroundStyle(AppTheme.charcoal)
                                Text(comment.date.timeAgoDisplay())
                                    .font(AppTheme.sansFont(.caption2))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }
                            Text(comment.text)
                                .font(AppTheme.sansFont(.caption))
                                .foregroundStyle(AppTheme.charcoal)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Escreva um comentário...", text: $commentText, axis: .vertical)
                    .font(AppTheme.sansFont(.caption))
                    .lineLimit(3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.cream)
                    .clipShape(.rect(cornerRadius: 20))

                Button {
                    let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onComment(trimmed)
                    commentText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.creamDark : AppTheme.rose)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.top, 4)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = -self.timeIntervalSinceNow
        if seconds < 60 { return "agora" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(Int(minutes))min" }
        let hours = minutes / 60
        if hours < 24 { return "\(Int(hours))h" }
        let days = hours / 24
        if days < 7 { return "\(Int(days))d" }
        return self.formatted(.dateTime.day().month(.abbreviated))
    }
}
