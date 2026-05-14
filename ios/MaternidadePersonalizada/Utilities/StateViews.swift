import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.charcoalLight.opacity(0.3))

            VStack(spacing: 6) {
                Text(title)
                    .font(AppTheme.sansFont(.body, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Text(message)
                    .font(AppTheme.sansFont(.subheadline))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(AppTheme.rose)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct LoadingStateView: View {
    var message: String = "Carregando..."

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(AppTheme.rose)
            Text(message)
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoalLight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.roseDark.opacity(0.5))

            VStack(spacing: 6) {
                Text("Algo deu errado")
                    .font(AppTheme.sansFont(.body, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Text(message)
                    .font(AppTheme.sansFont(.subheadline))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .multilineTextAlignment(.center)
            }

            if let retryAction {
                Button(action: retryAction) {
                    Text("Tentar novamente")
                        .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(AppTheme.rose)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
