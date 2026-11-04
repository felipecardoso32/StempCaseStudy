// xcode: set sdk=iOS

//
//  ContentView.swift
//  StempCaseStudy
//
//  Mesma TabBar do AppTabBarView original. A primeira aba (antes "Registros",
//  com calendário e slider de presença) virou "Desafios": o formulário que
//  alimenta Eventos, Dashboard e o Widget.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: EventStore

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.bg900)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                CreateChallengeView()
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Image(systemName: "square.and.pencil")
                Text("Desafios")
            }

            DashboardView()
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tabItem {
                    Image(systemName: "rectangle.3.offgrid")
                    Text("Dashboard")
                }

            EventsView()
                .badge(store.newEventsCount)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Eventos")
                }

            NavigationStack {
                StudyCasePlaceholderView(title: "Perfil", icon: "person.crop.circle.fill")
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Image(systemName: "person.fill")
                Text("Perfil")
            }
        }
        .accentColor(Color.gradientStart)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(EventStore())
}
