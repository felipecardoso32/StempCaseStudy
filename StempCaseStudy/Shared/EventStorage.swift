//
//  EventStorage.swift
//  StempCaseStudy  ·  Shared (App + Widget)
//
//  Camada de persistência compartilhada via App Group.
//  O app grava aqui; o Widget (WidgetKit) lê daqui.
//
//  ⚠️ Troque `appGroupID` pelo App Group que você criar em
//  Signing & Capabilities (no target do App E no target do Widget).
//  Se o App Group não existir, cai no UserDefaults.standard
//  (o app funciona, mas o Widget não enxerga os dados).
//
import Foundation

enum EventStorage {
    static let appGroupID = "group.com.felipe.stempcasestudy"
    static let eventsKey = "cachedEvents"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    static func loadEvents() -> [EventDetail] {
        guard let data = defaults.data(forKey: eventsKey),
              let events = try? decoder.decode([EventDetail].self, from: data)
        else { return [] }
        return events
    }

    static func saveEvents(_ events: [EventDetail]) {
        guard let data = try? encoder.encode(events) else { return }
        defaults.set(data, forKey: eventsKey)
    }

    /// Mesma regra do Airtable original: `{Datetime} >= TODAY()`, ordenado por data crescente.
    static func upcoming(_ events: [EventDetail], from now: Date = Date()) -> [EventDetail] {
        let startOfToday = Calendar.current.startOfDay(for: now)
        return events
            .filter { $0.time >= startOfToday }
            .sorted { $0.time < $1.time }
    }
}
