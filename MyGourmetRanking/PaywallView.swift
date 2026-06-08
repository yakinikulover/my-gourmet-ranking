import SwiftUI

enum PaywallReason: Identifiable {
    case archiveLimit
    case genreEditing
    case mapFullAccess
    case settings

    var id: String { title }

    var title: String {
        switch self {
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
        case .archiveLimit:
            "無料プランではアーカイブは3件まで保存できます。Proにすると、過去の名店を無制限に残せます。"
        case .genreEditing:
            "ジャンル・種類編集はPro限定です。自分だけの分類でランキングを育てられます。"
        case .mapFullAccess:
            "無料プランのMapは各カテゴリのBest1のみ表示されます。Proで全店舗・Archive・フィルターを使えます。"
        case .settings:
            "アーカイブ無制限、ジャンル編集、グルメMap解放で、行った店・行きたい店・過去の名店をすべて整理できます。"
        }
    }
}

struct PaywallView: View {
    @EnvironmentObject private var proState: ProState
    @Environment(\.dismiss) private var dismiss
    let reason: PaywallReason

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Proで自分だけのグルメランキング帳を完全解放")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text(reason.message)
                            .font(.body)
                            .foregroundStyle(AppTheme.softText)
                            .lineSpacing(5)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("アーカイブ無制限", icon: "archivebox.fill")
                        featureRow("ジャンル・種類編集", icon: "slider.horizontal.3")
                        featureRow("グルメMap完全解放", icon: "map.fill")
                        featureRow("過去の名店を残せる", icon: "bookmark.fill")
                        featureRow("自分好みの分類でランキングを作れる", icon: "tag.fill")
                    }
                    .padding(16)
                    .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 16))

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
            .background(AppBackgroundView())
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
        }
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
