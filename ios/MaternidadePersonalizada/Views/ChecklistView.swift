import SwiftUI

struct ChecklistView: View {
    let stage: MaternalStage
    let pregnancyWeek: Int?
    @State private var completedItems: Set<String> = []

    private var title: String {
        switch stage {
        case .trying: return "Checklist de Fertilidade"
        case .pregnant: return "Checklist da Semana \(pregnancyWeek ?? 20)"
        case .postpartum: return "Cuidados do Dia"
        case .mother: return "Checklist do Dia"
        }
    }

    private var items: [ChecklistSection] {
        switch stage {
        case .trying:
            return [
                ChecklistSection(title: "Saúde & Corpo", icon: "heart.fill", color: AppTheme.rose, items: [
                    "Tomar ácido fólico",
                    "Registrar temperatura basal",
                    "Beber 2L de água",
                    "Praticar exercício leve (30 min)",
                ]),
                ChecklistSection(title: "Nutrição", icon: "leaf.fill", color: AppTheme.sage, items: [
                    "Consumir alimentos ricos em ferro",
                    "Incluir frutas e vegetais frescos",
                    "Evitar álcool e cafeína em excesso",
                ]),
                ChecklistSection(title: "Bem-estar", icon: "sparkles", color: AppTheme.roseDark, items: [
                    "Momento de relaxamento",
                    "Anotar sintomas do ciclo",
                    "Conversar com seu parceiro(a)",
                ]),
            ]
        case .pregnant:
            let week = pregnancyWeek ?? 20
            let trimesterItems: [String]
            if week <= 12 {
                trimesterItems = [
                    "Tomar vitaminas pré-natais",
                    "Agendar ultrassom do 1º trimestre",
                    "Descansar quando sentir enjoo",
                    "Evitar alimentos crus",
                ]
            } else if week <= 27 {
                trimesterItems = [
                    "Tomar vitaminas pré-natais",
                    "Praticar exercícios leves",
                    "Contar movimentos do bebê",
                    "Hidratar a barriga",
                ]
            } else {
                trimesterItems = [
                    "Tomar vitaminas pré-natais",
                    "Preparar a bolsa maternidade",
                    "Praticar respiração para o parto",
                    "Montar o quarto do bebê",
                ]
            }
            return [
                ChecklistSection(title: "Cuidados da semana", icon: "calendar.badge.clock", color: AppTheme.rose, items: trimesterItems),
                ChecklistSection(title: "Bem-estar", icon: "leaf.fill", color: AppTheme.sage, items: [
                    "Beber bastante água",
                    "Caminhar 20 minutos",
                    "Momento de conexão com o bebê",
                ]),
            ]
        case .postpartum:
            return [
                ChecklistSection(title: "Cuidados com você", icon: "heart.fill", color: AppTheme.rose, items: [
                    "Descansar sempre que possível",
                    "Beber 2L de água",
                    "Fazer refeições nutritivas",
                    "Cuidar da cicatrização",
                ]),
                ChecklistSection(title: "Cuidados com o bebê", icon: "star.fill", color: AppTheme.sage, items: [
                    "Registrar mamadas/fraldas",
                    "Banho de sol (15 min)",
                    "Tempo de barriguinha (tummy time)",
                ]),
                ChecklistSection(title: "Emocional", icon: "brain.head.profile.fill", color: AppTheme.roseDark, items: [
                    "Pedir ajuda quando precisar",
                    "Momento só seu (10 min)",
                    "Conversar com alguém de confiança",
                ]),
            ]
        case .mother:
            return [
                ChecklistSection(title: "Rotina", icon: "clock.fill", color: AppTheme.rose, items: [
                    "Organizar agenda do dia",
                    "Beber bastante água",
                    "Fazer uma refeição nutritiva",
                    "Praticar exercício (20 min)",
                ]),
                ChecklistSection(title: "Conexão", icon: "heart.fill", color: AppTheme.sage, items: [
                    "Atividade com o(a) filho(a)",
                    "Momento de leitura juntos",
                    "Elogiar uma conquista",
                ]),
                ChecklistSection(title: "Autocuidado", icon: "sparkles", color: AppTheme.roseDark, items: [
                    "Tempo só para você (15 min)",
                    "Gratidão: 3 coisas boas do dia",
                ]),
            ]
        }
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerCard

                    ForEach(items) { section in
                        sectionCard(section)
                    }
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
                Text(title)
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
        .onAppear {
            loadCompleted()
        }
    }

    private var headerCard: some View {
        let total = items.flatMap(\.items).count
        let done = completedItems.count
        let progress = total > 0 ? Double(done) / Double(total) : 0

        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(done) de \(total)")
                        .font(AppTheme.serifFont(.title2, weight: .bold))
                        .foregroundStyle(AppTheme.charcoal)
                    Text("tarefas concluídas")
                        .font(AppTheme.sansFont(.subheadline))
                        .foregroundStyle(AppTheme.charcoalLight)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(AppTheme.creamDark, lineWidth: 6)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.rose, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progress * 100))%")
                        .font(AppTheme.sansFont(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.rose)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.creamDark)
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.rose, AppTheme.roseDark],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(duration: 0.4), value: progress)
                }
            }
            .frame(height: 6)
        }
        .warmCard()
    }

    private func sectionCard(_ section: ChecklistSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.caption)
                    .foregroundStyle(section.color)
                Text(section.title)
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Spacer()
                let done = section.items.filter { completedItems.contains($0) }.count
                Text("\(done)/\(section.items.count)")
                    .font(AppTheme.sansFont(.caption, weight: .medium))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            ForEach(section.items, id: \.self) { item in
                let isCompleted = completedItems.contains(item)
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        if isCompleted {
                            completedItems.remove(item)
                        } else {
                            completedItems.insert(item)
                        }
                        saveCompleted()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(isCompleted ? AppTheme.sage : AppTheme.creamDark)

                        Text(item)
                            .font(AppTheme.sansFont(.body))
                            .foregroundStyle(isCompleted ? AppTheme.charcoalLight : AppTheme.charcoal)
                            .strikethrough(isCompleted, color: AppTheme.charcoalLight)

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: isCompleted)
            }
        }
        .warmCard()
    }

    private var storageKey: String {
        "checklist_\(stage.rawValue)_\(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970)"
    }

    private func saveCompleted() {
        if let data = try? JSONEncoder().encode(Array(completedItems)) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadCompleted() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let items = try? JSONDecoder().decode([String].self, from: data) {
            completedItems = Set(items)
        }
    }
}

nonisolated struct ChecklistSection: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let items: [String]
}
