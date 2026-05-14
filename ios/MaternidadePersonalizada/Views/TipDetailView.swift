import SwiftUI

struct TipDetailView: View {
    let stage: MaternalStage

    private var tip: DailyTip {
        DailyTip.forStage(stage)
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerCard

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(tip.sections.enumerated()), id: \.offset) { index, section in
                            tipSection(section, index: index)
                        }
                    }

                    sourceNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Dica do Dia")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseLight)
                        .frame(width: 48, height: 48)
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.roseDark)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tip.category)
                        .font(AppTheme.sansFont(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.roseDark)
                    Text(Date().formatted(.dateTime.day().month(.wide).year()))
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                }

                Spacer()

                Text(stage.emoji)
                    .font(.title2)
            }

            Text(tip.title)
                .font(AppTheme.serifFont(.title2, weight: .bold))
                .foregroundStyle(AppTheme.charcoal)
                .fixedSize(horizontal: false, vertical: true)

            Text(tip.summary)
                .font(AppTheme.sansFont(.body))
                .foregroundStyle(AppTheme.charcoalLight)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .warmCard()
    }

    private func tipSection(_ section: TipSection, index: Int) -> some View {
        let colors: [Color] = [AppTheme.sage, AppTheme.rose, AppTheme.roseDark, AppTheme.sageDark]
        let color = colors[index % colors.count]

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(section.title)
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            Text(section.body)
                .font(AppTheme.sansFont(.body))
                .foregroundStyle(AppTheme.charcoal.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .warmCard()
    }

    private var sourceNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundStyle(AppTheme.charcoalLight.opacity(0.5))
            Text("Dicas baseadas em orientações gerais de saúde. Consulte sempre seu médico.")
                .font(AppTheme.sansFont(.caption))
                .foregroundStyle(AppTheme.charcoalLight.opacity(0.6))
        }
        .padding(.horizontal, 4)
    }
}

nonisolated struct TipSection: Sendable {
    let icon: String
    let title: String
    let body: String
}

nonisolated struct DailyTip: Sendable {
    let category: String
    let title: String
    let summary: String
    let sections: [TipSection]

    static func forStage(_ stage: MaternalStage) -> DailyTip {
        switch stage {
        case .trying:
            return DailyTip(
                category: "Nutrição e Fertilidade",
                title: "Alimentos que ajudam na fertilidade",
                summary: "A alimentação é uma grande aliada na preparação do corpo para a gestação. Veja como ajustar sua dieta.",
                sections: [
                    TipSection(icon: "leaf.fill", title: "Ácido fólico", body: "Comece a tomar ácido fólico pelo menos 3 meses antes de tentar engravidar. Alimentos como espinafre, brócolis e lentilha são ricos nesse nutriente essencial."),
                    TipSection(icon: "drop.fill", title: "Hidratação", body: "Beber pelo menos 2 litros de água por dia ajuda a manter o muco cervical saudável e favorece a fertilidade."),
                    TipSection(icon: "flame.fill", title: "Evite ultraprocessados", body: "Alimentos ultraprocessados podem impactar negativamente os hormônios reprodutivos. Prefira comida de verdade e preparações caseiras."),
                ]
            )
        case .pregnant:
            return DailyTip(
                category: "Alimentação na Gestação",
                title: "Nutrientes essenciais para você e seu bebê",
                summary: "Durante a gestação, seu corpo precisa de nutrientes extras. Veja os mais importantes para cada trimestre.",
                sections: [
                    TipSection(icon: "leaf.fill", title: "Ferro e proteína", body: "O volume de sangue aumenta até 50% na gravidez. Carnes magras, feijão e folhas verde-escuras ajudam a manter os níveis de ferro adequados."),
                    TipSection(icon: "sun.max.fill", title: "Vitamina D", body: "Essencial para a formação óssea do bebê. Tome sol pela manhã por 15 minutos e converse com seu médico sobre suplementação."),
                    TipSection(icon: "fish.fill", title: "Ômega-3", body: "Importante para o desenvolvimento cerebral do bebê. Sardinha, salmão e chia são ótimas fontes. Evite peixes com alto teor de mercúrio."),
                ]
            )
        case .postpartum:
            return DailyTip(
                category: "Recuperação Pós-parto",
                title: "Cuidando de você no puerpério",
                summary: "O pós-parto exige cuidados especiais com seu corpo e mente. Veja dicas práticas para o dia a dia.",
                sections: [
                    TipSection(icon: "heart.fill", title: "Alimentação para amamentação", body: "Se estiver amamentando, inclua grãos integrais, proteínas e muitos líquidos. Evite dietas restritivas neste momento."),
                    TipSection(icon: "moon.fill", title: "Sono e descanso", body: "Durma quando o bebê dormir. Aceite ajuda para as tarefas domésticas. Seu corpo precisa de tempo para se recuperar."),
                    TipSection(icon: "person.2.fill", title: "Rede de apoio", body: "Não tenha vergonha de pedir ajuda. Conversar sobre seus sentimentos com alguém de confiança é fundamental para sua saúde emocional."),
                ]
            )
        case .mother:
            return DailyTip(
                category: "Alimentação e Bem-estar",
                title: "Energia e disposição para o dia a dia",
                summary: "Manter a energia em alta é essencial para acompanhar o ritmo dos filhos. Confira dicas práticas.",
                sections: [
                    TipSection(icon: "bolt.fill", title: "Snacks inteligentes", body: "Tenha sempre à mão opções saudáveis: frutas picadas, castanhas, iogurte natural. Comer a cada 3 horas mantém a energia estável."),
                    TipSection(icon: "figure.walk", title: "Movimento diário", body: "Não precisa ser academia. Uma caminhada de 20 minutos, alongamento ou dançar com os filhos já faz diferença no humor e disposição."),
                    TipSection(icon: "cup.and.saucer.fill", title: "Ritual de autocuidado", body: "Reserve pelo menos 15 minutos por dia só para você. Um chá, uma leitura, um banho mais demorado — pequenos rituais renovam as energias."),
                ]
            )
        }
    }
}
