//
//  EventsView.swift
//  StempCaseStudy
//
//  Layout idêntico ao EventsView original.
//
import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var store: EventStore

    var body: some View {
        NavigationView {
            ZStack {
                Color.bg950.ignoresSafeArea(edges: .all)
                if !store.upcomingEvents.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 25) {
                            ForEach(store.upcomingEvents) { event in
                                EventItem(
                                    eventInfos: event,
                                    isNew: store.isNew(event),
                                    openEventDetail: { store.markAsSeen(event) },
                                    onDelete: { store.remove(id: event.id) }
                                )
                            }
                        }
                        .padding(.top, 10)
                    }
                } else {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "star.slash.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(.white)
                            Text("Sem eventos")
                                .font(.system(size: 30))
                                .bold()
                                .foregroundStyle(.white)
                        }
                    } description: {
                        VStack {
                            Text("Nenhum evento encontrado.")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.4))
                            Text("Crie um desafio na aba Desafios para ele aparecer aqui.")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
            }
            .navigationTitle("Eventos")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(EventStore())
}
