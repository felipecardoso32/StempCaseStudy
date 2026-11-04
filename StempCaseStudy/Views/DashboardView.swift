//
//  DashboardView.swift
//  StempCaseStudy
//
//  Layout idêntico ao DashboardView original. Frequência é fictícia
//  (valores fixos); o "Próximo evento" vem do EventStore.
//
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: EventStore

    // Dados fictícios de frequência
    private let presences = 140
    private let absences = 3
    private let delays = 17

    private var attendanceStatus: (label: String, color: Color) {
        switch absences {
        case 0: return ("Ótimo", Color(hex: "#1D9E75"))
        case 1...3: return ("Atenção", Color(hex: "#EF9F27"))
        default: return ("Crítico", Color(hex: "#D85A30"))
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bg950.ignoresSafeArea()
                VStack(spacing: 15) {
                    AttendanceProgressChart(
                        presences: presences,
                        absences: absences,
                        delays: delays
                    )
                    AttendanceStatusCard(
                        status: attendanceStatus,
                        absences: absences
                    )
                    if let event = store.nextEvent {
                        NextEventCard(event: event)
                    } else {
                        ContentUnavailableView {
                            VStack {
                                Image(systemName: "star.slash.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white)
                                Text("Sem eventos. Novos eventos em breve!")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Dashboard")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(EventStore())
}
