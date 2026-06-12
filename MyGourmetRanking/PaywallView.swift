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

    private struct ProFeature: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
    }

    private let features: [ProFeature] = [
        .init(icon: "archivebox.fill",
              title: "Archiveを無制限に",
              detail: "過去の名店も惜しくも圏外の店も、何件でも残せる"),
        .init(icon: "map.fill",
              title: "グルメMapを完全解放",
              detail: "全店舗・Archive・フィルターを地図で見渡せる"),
        .init(icon: "slider.horizontal.3",
              title: "ジャンル・種類を自由に編集",
              detail: "自分だけの分類でランキングを育てられる")
    ]

    private var proFeatures: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(features) { feature in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.tomato)
                        .frame(width: 30, height: 30)
                        .background(AppTheme.tomato.opacity(0.1), in: Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        Text(feature.detail)
                            .font(.caption)
                            .foregroundStyle(AppTheme.softText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: 320)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 12)

                    Image(systemName: reason.heroIcon)
                        .font(.system(size: 40, weight: .regular))
                        .foregroundStyle(AppTheme.tomato)
                        .padding(.bottom, 26)

                    Text(reason.heroTitle)
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)

                    Spacer()

                    proFeatures
                        .padding(.horizontal, 8)

                    Spacer()

                    VStack(spacing: 14) {
                        Button {
                            Task { await proState.purchasePro() }
                        } label: {
                            Text(proState.isLoading ? "処理中..." : "Proを購入する \(proState.displayPrice)")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.tomato)
                        .controlSize(.large)
                        .disabled(proState.isLoading || proState.isPro)

                        Text("買い切り・一度の購入でずっと使えます")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)

                        HStack(spacing: 20) {
                            Button("購入を復元") {
                                Task { await proState.restorePurchases() }
                            }
                            Link("利用規約", destination: StoreConfig.termsURL)
                            Link("プライバシーポリシー", destination: StoreConfig.privacyURL)
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
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
}
