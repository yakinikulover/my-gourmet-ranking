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
                AppBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        paywallHero

                        Text(reason.message)
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.softText)
                            .lineSpacing(5)

                        Text("買い切りPro")
                            .font(.caption.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(AppTheme.tomato)

                        Text("一度の購入で、ずっと使えます。")
                            .font(.title3.weight(.black))
                            .foregroundStyle(AppTheme.ink)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("アーカイブ無制限", icon: "archivebox.fill")
                        featureRow("ジャンル・種類編集", icon: "slider.horizontal.3")
                        featureRow("グルメMap完全解放", icon: "map.fill")
                    }
                    .padding(18)
                    .modernCard(cornerRadius: 18)

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

                        Button("無料ではじめる") {
                            dismiss()
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.softText)
                        .padding(.top, 2)

                        Button {
                            Task { await proState.restorePurchases() }
                        } label: {
                            Text("購入を復元")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(proState.isLoading)
                    }

                    HStack(spacing: 16) {
                        Link("利用規約", destination: RevenueCatConfig.termsURL)
                        Link("プライバシーポリシー", destination: RevenueCatConfig.privacyURL)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.olive)
                    .frame(maxWidth: .infinity)
                    }
                    .padding(22)
                }
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

    private var paywallHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.ink)
                .frame(height: 245)

            Circle()
                .fill(AppTheme.tomato)
                .frame(width: 180, height: 180)
                .offset(x: 220, y: -80)

            Image(systemName: reason.heroIcon)
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(AppTheme.background)
                .rotationEffect(.degrees(-8))
                .offset(x: 245, y: -118)

            VStack(alignment: .leading, spacing: 12) {
                Text(reason.eyebrow)
                    .font(.caption.weight(.black))
                    .tracking(1.3)
                    .foregroundStyle(AppTheme.tomato)
                Text(reason.heroTitle)
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.background)
                    .lineSpacing(2)
            }
            .padding(22)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppTheme.ink.opacity(0.18), radius: 20, y: 10)
    }

    private func featureRow(_ title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.tomato)
                .frame(width: 24)
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.ink)
        }
    }
}
