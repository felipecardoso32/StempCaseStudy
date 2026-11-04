//
//  CreateChallengeView.swift
//  StempCaseStudy
//
//  Substitui a tela "Registros" (calendário). Aqui o "mentor" cria desafios,
//  workshops, apresentações etc. com dados fictícios. O que for criado aparece
//  em Eventos e no Dashboard e fica salvo no App Group para o Widget.
//
import SwiftUI

struct CreateChallengeView: View {
    @EnvironmentObject private var store: EventStore

    @State private var kind: EventKind = .challenge
    @State private var name: String = ""
    @State private var date: Date = CreateChallengeView.defaultDate()
    @State private var descriptionText: String = ""
    @State private var icon: String = EventKind.challenge.defaultIcon
    @State private var colorHex: String = EventKind.challenge.defaultColorHex
    @State private var materials: [SupportMaterial] = []
    @State private var deliverables: [Deliverable] = []

    @State private var showCreatedAlert = false
    @State private var showClearConfirm = false
    @FocusState private var focused: Bool

    private static let iconOptions: [String] = [
        "sparkle.text.clipboard.fill", "book.and.wrench.fill", "play.tv",
        "ruler.fill", "figure.socialdance.circle.fill", "apple.logo",
        "brain.head.profile.fill", "star.fill", "flag.checkered", "laptopcomputer"
    ]

    private static let colorOptions: [String] = [
        "#EF9F27", "#378ADD", "#7F77DD", "#1D9E75",
        "#639922", "#E98049", "#DF537E", "#4067D0"
    ]

    private static func defaultDate() -> Date {
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return cal.date(bySettingHour: 14, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    studyCaseBanner
                    typeSection
                    basicsSection
                    appearanceSection
                    materialsSection
                    deliverablesSection
                    createButton
                    createdListSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Novo desafio")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button {
                        store.loadSamples()
                    } label: {
                        Label("Carregar exemplos fictícios", systemImage: "wand.and.stars")
                    }
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label("Apagar todos", systemImage: "trash")
                    }
                    .disabled(store.events.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onChange(of: kind) { _, newKind in
            icon = newKind.defaultIcon
            colorHex = newKind.defaultColorHex
        }
        .alert("Desafio criado!", isPresented: $showCreatedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ele já aparece nas abas Eventos e Dashboard e está salvo para o Widget.")
        }
        .confirmationDialog("Apagar todos os eventos?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Apagar todos", role: .destructive) { store.removeAll() }
            Button("Cancelar", role: .cancel) {}
        }
    }

    // MARK: - Seções

    private var studyCaseBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.gradientStart)
            Text("Estudo de caso: os dados abaixo são fictícios e substituem o que os mentores preenchem no Airtable.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var typeSection: some View {
        FormCard(title: "Tipo de evento", icon: "tag.fill") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EventKind.allCases) { option in
                        let selected = option == kind
                        let tint = Color(hex: option.defaultColorHex)
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { kind = option }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: option.defaultIcon)
                                    .font(.system(size: 12))
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(selected ? tint : .white.opacity(0.55))
                            .background(selected ? tint.opacity(0.18) : Color.white.opacity(0.05))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(selected ? tint.opacity(0.6) : .clear, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var basicsSection: some View {
        FormCard(title: "Informações", icon: "text.alignleft") {
            VStack(alignment: .leading, spacing: 14) {
                LabeledField(label: "Nome") {
                    StudyTextField(placeholder: "Ex.: Challenge 3 · Meu primeiro app", text: $name)
                        .focused($focused)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Data e hora")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "pt_BR"))
                        .colorScheme(.dark)
                }

                LabeledField(label: "Descrição (aceita **markdown** simples)") {
                    TextEditor(text: $descriptionText)
                        .focused($focused)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .frame(minHeight: 110)
                        .padding(8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var appearanceSection: some View {
        FormCard(title: "Aparência", icon: "paintpalette.fill") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Ícone")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Self.iconOptions, id: \.self) { symbol in
                            let selected = symbol == icon
                            Button { icon = symbol } label: {
                                Image(systemName: symbol)
                                    .font(.system(size: 18))
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(selected ? Color(hex: colorHex) : .white.opacity(0.5))
                                    .background(selected ? Color(hex: colorHex).opacity(0.15) : Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selected ? Color(hex: colorHex).opacity(0.6) : .clear, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text("Cor")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                HStack(spacing: 12) {
                    ForEach(Self.colorOptions, id: \.self) { hex in
                        Button { colorHex = hex } label: {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: colorHex == hex ? 2.5 : 0)
                                        .padding(-3)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 3)

                // Prévia fiel ao card da aba Eventos
                Text("Prévia")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 4)
                EventItem(eventInfos: previewEvent, isNew: false, openEventDetail: {})
                    .allowsHitTesting(false)
                    .padding(.horizontal, -5)
            }
        }
    }

    private var materialsSection: some View {
        FormCard(title: "Material de apoio", icon: "folder") {
            VStack(spacing: 12) {
                ForEach($materials) { $item in
                    VStack(spacing: 8) {
                        HStack {
                            StudyTextField(placeholder: "Nome do arquivo (ex.: Briefing.pdf)", text: $item.filename)
                            removeButton { materials.removeAll { $0.id == item.id } }
                        }
                        StudyTextField(placeholder: "https://…", text: $item.url, isURL: true)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                AddRowButton(title: "Adicionar material") {
                    materials.append(SupportMaterial())
                }
            }
        }
    }

    private var deliverablesSection: some View {
        FormCard(title: "Entregáveis e prazos", icon: "arrow.up.doc") {
            VStack(spacing: 12) {
                ForEach($deliverables) { $item in
                    VStack(spacing: 8) {
                        HStack {
                            StudyTextField(placeholder: "Título (ex.: Código, Keynote)", text: $item.title)
                            removeButton { deliverables.removeAll { $0.id == item.id } }
                        }
                        HStack {
                            Text("Entrega")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                            Spacer()
                            DatePicker("", selection: $item.dueDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .environment(\.locale, Locale(identifier: "pt_BR"))
                                .colorScheme(.dark)
                        }
                        StudyTextField(placeholder: "Link do entregável (https://…)", text: $item.url, isURL: true)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                AddRowButton(title: "Adicionar entregável") {
                    deliverables.append(Deliverable(dueDate: max(date, Date())))
                }
            }
        }
    }

    private var createButton: some View {
        Button(action: createChallenge) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Criar desafio")
                    .fontWeight(.semibold)
            }
            .font(.system(size: 17))
            .foregroundStyle(.black.opacity(0.85))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                LinearGradient(
                    colors: [.gradientStart, .gradientEnd],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isValid ? 1 : 0.35)
        }
        .disabled(!isValid)
        .padding(.top, 4)
    }

    @ViewBuilder
    private var createdListSection: some View {
        if !store.events.isEmpty {
            FormCard(title: "Criados (\(store.events.count))", icon: "checklist") {
                VStack(spacing: 0) {
                    ForEach(store.events.sorted { $0.time < $1.time }) { event in
                        HStack(spacing: 12) {
                            Image(systemName: event.icon)
                                .foregroundStyle(Color(hex: event.colorHex))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(event.formattedDateTime)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            Spacer()
                            Button { store.remove(id: event.id) } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.35))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 10)
                        if event.id != store.events.sorted(by: { $0.time < $1.time }).last?.id {
                            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Ações

    private var previewEvent: EventDetail {
        EventDetail(
            name: name.isEmpty ? "Nome do desafio" : name,
            typeEvent: kind.rawValue,
            time: date,
            icon: icon,
            colorHex: colorHex
        )
    }

    private func createChallenge() {
        focused = false
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanMaterials = materials
            .filter { !$0.filename.trimmingCharacters(in: .whitespaces).isEmpty }
        let cleanDeliverables = deliverables
            .filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }

        let event = EventDetail(
            name: trimmedName,
            typeEvent: kind.rawValue,
            time: date,
            icon: icon,
            colorHex: colorHex,
            description: trimmedDesc.isEmpty ? nil : trimmedDesc,
            supportMaterial: cleanMaterials,
            deliverables: cleanDeliverables
        )
        store.add(event)
        resetForm()
        showCreatedAlert = true
    }

    private func resetForm() {
        name = ""
        descriptionText = ""
        materials = []
        deliverables = []
        date = Self.defaultDate()
        kind = .challenge
        icon = kind.defaultIcon
        colorHex = kind.defaultColorHex
    }

    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.red.opacity(0.7))
                .font(.system(size: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Componentes de formulário

private struct FormCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .foregroundStyle(.white.opacity(0.4))

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct LabeledField<Content: View>: View {
    let label: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            content
        }
    }
}

private struct StudyTextField: View {
    let placeholder: String
    @Binding var text: String
    var isURL: Bool = false

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundColor(.white.opacity(0.28))
        )
        .keyboardType(isURL ? .URL : .default)
        .textInputAutocapitalization(isURL ? .never : .sentences)
        .autocorrectionDisabled(isURL)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct AddRowButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                Text(title)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.gradientStart)
            .frame(maxWidth: .infinity, minHeight: 42)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gradientStart.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CreateChallengeView()
    }
    .environmentObject(EventStore())
}
