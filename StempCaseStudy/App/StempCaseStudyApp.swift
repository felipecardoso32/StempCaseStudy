//
//  StempCaseStudyApp.swift
//  StempCaseStudy
//
//  Recorte de estudo de caso do app "Stemp" (Apple Developer Academy).
//  Sem API, sem login, sem Airtable.
//
import SwiftUI

@main
struct StempCaseStudyApp: App {
    @StateObject private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
