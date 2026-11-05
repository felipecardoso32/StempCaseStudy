//
//  StempWidget.swift
//  StempWidget
//
//  Created by Felipe Colares Cardoso on 04/11/26.
//
//
//  StempWidget.swift
//  StempWidget
//
//  Widget que lê os eventos salvos pelo app (via App Group / EventStorage).
//
//  • systemSmall  → 1 evento (o mais próximo)
//  • systemMedium → até 2 eventos (hoje + próximo)
//  • Large e ExtraLarge bloqueados em `.supportedFamilies`
//
//  ⚠️ Target Membership: marque o target "StempWidget" nos arquivos
//  EventStorage.swift, EventDetail.swift e ColorExtension.swift
//  (e o App Group também precisa estar ligado no target do Widget).
//

import WidgetKit
import SwiftUI

// MARK: - Tema (local, não depende do Theme.swift do app)

private enum WidgetTheme {
    static let accent = Color(hex: "#EF9F27")
    static let secondaryText = Color.white.opacity(0.5)
    static let cardBackground = Color.white.opacity(0.06)

    static var smallBackground: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#1B2340"), Color(hex: "#141B2E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var mediumBackground: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#0D1220"), Color(hex: "#080B14")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Formatação (pt_BR)

private enum WidgetFormat {
    private static let locale = Locale(identifier: "pt_BR")

    private static func make(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = locale
        f.dateFormat = format
        return f
    }

    /// "QUINTA-FEIRA"
    static func weekday(_ date: Date) -> String {
        make("EEEE").string(from: date).uppercased(with: locale)
    }

    /// "13"
    static func day(_ date: Date) -> String { make("d").string(from: date) }

    /// "18:00"
    static func time(_ date: Date) -> String { make("HH:mm").string(from: date) }

    /// "12 nov."
    static func shortDate(_ date: Date) -> String { make("d MMM").string(from: date) }
}

// MARK: - Helpers do modelo

private extension EventDetail {
    var accent: Color { Color(hex: colorHex) }

    /// "Challenge 6 - Apple Technologies" → ("Challenge 6", "Apple Technologies").
    /// Sem separador, usa o tipo do evento como prefixo.
    var nameParts: (prefix: String, title: String) {
        for separator in [" · ", " - ", " – "] {
            if let range = name.range(of: separator) {
                let prefix = String(name[..<range.lowerBound])
                let title = String(name[range.upperBound...])
                if !prefix.isEmpty && !title.isEmpty { return (prefix, title) }
            }
        }
        return (typeEvent, name)
    }

    func isToday(relativeTo reference: Date) -> Bool {
        Calendar.current.isDate(time, inSameDayAs: reference)
    }

    func badgeText(relativeTo reference: Date) -> String {
        let cal = Calendar.current
        if isToday(relativeTo: reference) { return "HOJE" }
        if let tomorrow = cal.date(byAdding: .day, value: 1, to: reference),
           cal.isDate(time, inSameDayAs: tomorrow) {
            return "AMANHÃ"
        }
        return WidgetFormat.shortDate(time).uppercased()
    }
}

// MARK: - Timeline

struct StempEntry: TimelineEntry {
    let date: Date
    let events: [EventDetail]
}

struct Provider: TimelineProvider {
    /// Máximo de eventos por entrada (o Medium mostra 2).
    private let maxEvents = 2

    func placeholder(in context: Context) -> StempEntry {
        StempEntry(date: .now, events: StempEntry.sampleEvents)
    }

    func getSnapshot(in context: Context, completion: @escaping (StempEntry) -> Void) {
        let all = EventStorage.loadEvents().sorted { $0.time < $1.time }
        let events = upcoming(in: all, at: .now)
        let shown = (events.isEmpty && context.isPreview) ? StempEntry.sampleEvents : events
        completion(StempEntry(date: .now, events: shown))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StempEntry>) -> Void) {
        let now = Date()
        let all = EventStorage.loadEvents().sorted { $0.time < $1.time }

        // Uma entrada agora + uma logo após cada evento passar
        // (para ele sair do widget) + uma à meia-noite (troca o dia exibido).
        var dates: Set<Date> = [now]

        for event in all where event.time > now {
            dates.insert(event.time.addingTimeInterval(1))
        }

        if let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) {
            dates.insert(midnight)
        }

        let entries = dates.sorted().prefix(15).map { date in
            StempEntry(date: date, events: upcoming(in: all, at: date))
        }

        completion(Timeline(entries: Array(entries), policy: .atEnd))
    }

    /// Eventos que ainda não passaram na data da entrada, ordenados.
    private func upcoming(in all: [EventDetail], at date: Date) -> [EventDetail] {
        Array(all.filter { $0.time >= date }.prefix(maxEvents))
    }
}

// MARK: - Componentes

private struct IconTile: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 32

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: size * 0.3))
    }
}

private struct DayBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy))
            .tracking(0.6)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.18), in: Capsule())
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "star.slash.fill")
                .font(.system(size: 22))
                .foregroundStyle(WidgetTheme.accent)
            Text("Sem eventos")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Text("Novos eventos em breve!")
                .font(.system(size: 10))
                .foregroundStyle(WidgetTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small

private struct SmallView: View {
    let entry: StempEntry

    var body: some View {
        if let event = entry.events.first {
            let parts = event.nameParts
            let today = event.isToday(relativeTo: entry.date)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    IconTile(symbol: event.icon, color: event.accent, size: 32)
                    Spacer(minLength: 4)
                    DayBadge(text: event.badgeText(relativeTo: entry.date), color: event.accent)
                }

                Spacer(minLength: 6)

                Text(parts.prefix)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WidgetTheme.secondaryText)
                    .lineLimit(1)

                Text(parts.title)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(event.accent)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .semibold))
                    Text(today ? "até \(WidgetFormat.time(event.time))"
                               : "às \(WidgetFormat.time(event.time))")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            EmptyStateView()
        }
    }
}

// MARK: - Medium

private struct EventRow: View {
    let event: EventDetail
    let now: Date
    let titleLines: Int

    private var subtitle: String {
        event.isToday(relativeTo: now)
            ? WidgetFormat.time(event.time)
            : "\(WidgetFormat.shortDate(event.time)) · \(WidgetFormat.time(event.time))"
    }

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.accent)
                .frame(width: 4)
                .padding(.vertical, 1)

            VStack(alignment: .leading, spacing: 1) {
                Text(event.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(titleLines)
                    .minimumScaleFactor(0.85)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(WidgetTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 2)

            Image(systemName: event.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(event.accent)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(WidgetTheme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MediumView: View {
    let entry: StempEntry

    private var rows: [EventDetail] { Array(entry.events.prefix(2)) }

    var body: some View {
        HStack(spacing: 10) {
            leftColumn
                .frame(width: 104, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)

            rightColumn
        }
    }

    // Dia da semana + número + atalho "Eventos"
    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(WidgetFormat.weekday(entry.date))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WidgetTheme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(WidgetFormat.day(entry.date))
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                IconTile(symbol: "sparkle.text.clipboard.fill", color: WidgetTheme.accent, size: 38)
                Text("Eventos")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    // Lista de eventos (até 2)
    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 5) {
            if rows.isEmpty {
                EmptyStateView()
            } else {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, event in
                    if let label = sectionLabel(at: index) {
                        Text(label)
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(WidgetTheme.secondaryText)
                    }
                    EventRow(event: event, now: entry.date, titleLines: index == 0 ? 2 : 1)
                }
            }
        }
    }

    /// Mostra "PRÓXIMO EVENTO(S)" antes do primeiro evento que não é de hoje.
    private func sectionLabel(at index: Int) -> String? {
        let cal = Calendar.current
        guard !cal.isDate(rows[index].time, inSameDayAs: entry.date) else { return nil }

        if index > 0, !cal.isDate(rows[index - 1].time, inSameDayAs: entry.date) {
            return nil
        }
        return (rows.count - index) > 1 ? "PRÓXIMOS EVENTOS" : "PRÓXIMO EVENTO"
    }
}

// MARK: - Entry View

struct StempWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StempEntry

    private var background: LinearGradient {
        family == .systemMedium ? WidgetTheme.mediumBackground : WidgetTheme.smallBackground
    }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                MediumView(entry: entry)
            default:
                SmallView(entry: entry)
            }
        }
        .containerBackground(for: .widget) { background }
    }
}

// MARK: - Widget

struct StempWidget: Widget {
    let kind: String = "StempWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StempWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Próximos eventos")
        .description("Acompanhe seus desafios e eventos da Academy.")
        // 🔒 Apenas pequeno e médio. Large e ExtraLarge não aparecem na galeria.
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Dados de exemplo (placeholder e Preview)

extension StempEntry {
    static var sampleEvents: [EventDetail] {
        let cal = Calendar.current
        let today18 = cal.date(bySettingHour: 18, minute: 0, second: 0, of: .now) ?? .now
        let nextWeek = cal.date(byAdding: .day, value: 7, to: today18) ?? today18

        return [
            EventDetail(
                name: "Challenge 6 - Apple Technologies",
                typeEvent: "Challenge",
                time: today18,
                icon: "sparkle.text.clipboard.fill",
                colorHex: "#EF9F27"
            ),
            EventDetail(
                name: "PoC presentation",
                typeEvent: "Apresentação",
                time: nextWeek,
                icon: "sparkle.text.clipboard.fill",
                colorHex: "#EF9F27"
            )
        ]
    }
}

#Preview("Pequeno", as: .systemSmall) {
    StempWidget()
} timeline: {
    StempEntry(date: .now, events: StempEntry.sampleEvents)
    StempEntry(date: .now, events: [])
}

#Preview("Médio", as: .systemMedium) {
    StempWidget()
} timeline: {
    StempEntry(date: .now, events: StempEntry.sampleEvents)
    StempEntry(date: .now, events: [])
}
