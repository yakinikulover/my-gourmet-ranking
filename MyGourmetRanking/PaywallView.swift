import SwiftUI

enum PaywallReason: Identifiable {
    case onboarding
    case archiveLimit
    case genreEditing
    case mapFullAccess
    case settings

    var id: String { title }

    var title: String {
        switch self {
        case .onboarding:
            "Proでもっと育てる"
        case .archiveLimit:
            "Archiveを無制限に残す"
        case .genreEditing:
            "自分好みの分類を作る"
        case .mapFullAccess:
            "グルメMapを完全解放"
        case .settings:
            "Proで完全解放"
        }
    }

    var message: String {
        switch self {
        case .onboarding:
            "ランキングを作るだけで終わらない。行った店が地図になり、過去の名店もずっと残せます。"
        case .archiveLimit:
            "無料プランでは各種類のアーカイブを3件まで保存できます。Proにすると、過去の名店を無制限に残せます。"
        case .genreEditing:
            "ジャンル・種類編集はPro限定です。自分だけの分類でランキングを育てられます。"
        case .mapFullAccess:
            "無料プランのMapは各カテゴリのBest1のみ表示されます。Proで全店舗・Archive・フィルターを使えます。"
        case .settings:
            "アーカイブ無制限、ジャンル編集、グルメMap解放で、行った店・行きたい店・過去の名店をすべて整理できます。"
        }
    }

    var eyebrow: String {
        switch self {
        case .onboarding: "YOUR GOURMET STORY"
        case .archiveLimit: "KEEP EVERY MEMORY"
        case .genreEditing: "MAKE IT YOURS"
        case .mapFullAccess: "SEE YOUR JOURNEY"
        case .settings: "MY GOURMET RANKING PRO"
        }
    }

    var heroTitle: String {
        switch self {
        case .onboarding: "食べた記憶を、\n自分だけの一冊に。"
        case .archiveLimit: "過去の名店も、\n忘れずに残そう。"
        case .genreEditing: "好きな分け方で、\nランキングを育てよう。"
        case .mapFullAccess: "行った店が、\n自分だけの地図になる。"
        case .settings: "うまい店帳を、\n完全解放。"
        }
    }

    var heroIcon: String {
        switch self {
        case .onboarding: "crown.fill"
        case .archiveLimit: "archivebox.fill"
        case .genreEditing: "tag.fill"
        case .mapFullAccess: "map.fill"
        case .settings: "sparkles"
        }
    }
}

struct PaywallView: View {
    @EnvironmentObject private var proState: ProState
    @Environment(\.dismiss) private var dismiss
    let reason: PaywallReason

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: reason.heroIcon)
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(AppTheme.tomato)

                    VStack(spacing: 10) {
                        Text(reason.heroTitle.replacingOccurrences(of: "\n", with: ""))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.center)

                        Text(reason.message)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.softText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: 310)
                    }

                    HStack(spacing: 16) {
                        featureChip("Archive無制限")
                        featureChip("Map完全解放")
                        featureChip("ジャンル編集")
                    }

                    VStack(spacing: 10) {
                        Button {
                            Task { await proState.purchasePro() }
                        } label: {
                            Text(proState.isLoading ? "処理中..." : "Proを購入する \(proState.displayPrice)")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.tomato)
                        .disabled(proState.isLoading || proState.isPro)

                        Text("買い切り。一度の購入でずっと使えます。")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                    }

                    Spacer()

                    HStack(spacing: 18) {
                        Button("無料ではじめる") { dismiss() }
                        Button("購入を復元") {
                            Task { await proState.restorePurchases() }
                        }
                        Link("利用規約", destination: RevenueCatConfig.termsURL)
                        Link("プライバシーポリシー", destination: RevenueCatConfig.privacyURL)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                }
                .padding(24)
            }
            .navigationTitle(reason.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .onChange(of: proState.isPro) { _, isPro in
                if isPro {
                    dismiss()
                }
            }
            .alert("Pro", isPresented: Binding(get: { proState.message != nil }, set: { if !$0 { proState.message = nil } })) {
                Button("OK") { proState.message = nil }
            } message: {
                Text(proState.message ?? "")
            }
        }
    }

    private func featureChip(_ title: String) -> some View {
        VStack(spacing: 7) {
            Circle()
                .fill(AppTheme.tomato.opacity(0.1))
                .frame(width: 7, height: 7)
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.softText)
        }
    }
}
