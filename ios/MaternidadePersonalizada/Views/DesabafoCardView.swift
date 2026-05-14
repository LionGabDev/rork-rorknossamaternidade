import SwiftUI

struct DesabafoCardView: View {
    let desabafo: Desabafo
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
                    Circle()
                        .fill(AppTheme.sageLight)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(String(desabafo.authorName.prefix(1)).uppercased())
                                .font(AppTheme.sansFont(.caption, weight: .bold))
                                .foregroundStyle(AppTheme.sageDark)
                        }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(desabafo.authorName)
                            .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.charcoal)
                        Text(desabafo.date.timeAgoDisplay())
                            .font(AppTheme.sansFont(.caption2))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }

                    Spacer()

                    Image(systemName: "shield.checkered")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.sage.opacity(0.6))
                }

                if !desabafo.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(desabafo.tags) { tag in
                            HStack(spacing: 3) {
                                Text(tag.emoji)
                                    .font(.system(size: 11))
                                Text(tag.label)
                                    .font(AppTheme.sansFont(.caption2, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.roseLight.opacity(0.4))
                            .foregroundStyle(AppTheme.roseDark)
                            .clipShape(.capsule)
                        }
                    }
                }

                Text(desabafo.text)
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
                            Image(systemName: desabafo.isLiked ? "heart.fill" : "heart")
                                .font(.body)
                                .foregroundStyle(desabafo.isLiked ? AppTheme.rose : AppTheme.charcoalLight)
                                .scaleEffect(likeScale)
                            if desabafo.likesCount > 0 {
                                Text("\(desabafo.likesCount)")
                                    .font(AppTheme.sansFont(.caption, weight: .medium))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: desabafo.isLiked)

                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showComments.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.body)
                                .foregroundStyle(AppTheme.charcoalLight)
                            if !desabafo.comments.isEmpty {
                                Text("\(desabafo.comments.count)")
                                    .font(AppTheme.sansFont(.caption, weight: .medium))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "hand.raised.fill")
                            .font(.caption2)
                        Text("Apoio")
                            .font(AppTheme.sansFont(.caption2, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.sage)
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
            if desabafo.comments.isEmpty {
                Text("Seja a primeira a apoiar essa mãe 💛")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .padding(.vertical, 4)
            } else {
                ForEach(desabafo.comments) { comment in
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
                TextField("Envie apoio...", text: $commentText, axis: .vertical)
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
