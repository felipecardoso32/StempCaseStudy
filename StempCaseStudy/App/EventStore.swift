//
//  EventStore.swift
//  StempCaseStudy
//
//  Substitui o Airtable + WebService + EventsViewModel do app original.
//  Fonte única da verdade para as telas "Desafios", "Dashboard" e "Eventos"
//  e, via EventStorage (App Group), para o Widget.
//

import SwiftUI
import Combine
import WidgetKit

final class EventStore: ObservableObject {

    @Published private(set) var events: [EventDetail] = []

    private let seenKey = "seenIdEvents"

    init() {
        events = EventStorage.loadEvents()
    }

    // MARK: - Leitura

    var upcomingEvents: [EventDetail] {
        EventStorage.upcoming(events)
    }

    var nextEvent: EventDetail? {
        upcomingEvents.first
    }

    var newEventsCount: Int {
        let seen = seenIds
        return upcomingEvents.filter {
            $0.time > Date() && !seen.contains($0.id)
        }.count
    }

    // MARK: - Escrita

    func add(_ event: EventDetail) {
        events.append(event)
        persist()
    }

    func remove(id: String) {
        events.removeAll { $0.id == id }
        persist()
    }

    func removeAll() {
        events.removeAll()
        persist()
    }

    func loadSamples() {
        events.append(contentsOf: SampleData.events())
        persist()
    }

    // MARK: - Eventos visualizados

    private var seenIds: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: seenKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: seenKey)
        }
    }

    func isNew(_ event: EventDetail) -> Bool {
        !seenIds.contains(event.id)
    }

    func markAsSeen(_ event: EventDetail) {
        seenIds.insert(event.id)
        objectWillChange.send()
    }

    // MARK: - Persistência

    private func persist() {
        EventStorage.saveEvents(events)

        let currentIds = Set(events.map(\.id))
        seenIds = seenIds.intersection(currentIds)

        WidgetCenter.shared.reloadAllTimelines()
    }
}
