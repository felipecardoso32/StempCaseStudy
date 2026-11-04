//
//  SampleData.swift
//  StempCaseStudy
//
//  Dados 100% fictícios, gerados relativos à data de hoje.
//
import Foundation

enum SampleData {
    static func events(from now: Date = Date()) -> [EventDetail] {
        let cal = Calendar.current

        func day(_ offset: Int, hour: Int, minute: Int = 0) -> Date {
            let base = cal.date(byAdding: .day, value: offset, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
        }

        func make(_ kind: EventKind,
                  _ name: String,
                  _ time: Date,
                  _ desc: String,
                  materials: [SupportMaterial] = [],
                  deliverables: [Deliverable] = []) -> EventDetail {
            EventDetail(
                name: name,
                typeEvent: kind.rawValue,
                time: time,
                icon: kind.defaultIcon,
                colorHex: kind.defaultColorHex,
                description: desc,
                supportMaterial: materials,
                deliverables: deliverables
            )
        }

        return [
            make(.challenge, "Challenge 3 · Meu primeiro app",
                 day(2, hour: 14),
                 "Desenvolva um **protótipo funcional** em SwiftUI resolvendo um problema do dia a dia.\n\nEntregue o código e uma apresentação curta.",
                 materials: [
                    SupportMaterial(filename: "Briefing-Challenge3.pdf", url: "https://example.com/briefing.pdf"),
                    SupportMaterial(filename: "Template-Keynote.key", url: "https://example.com/template.key")
                 ],
                 deliverables: [
                    Deliverable(title: "Código", dueDate: day(9, hour: 18), url: "https://example.com/ch3-code"),
                    Deliverable(title: "Keynote", dueDate: day(9, hour: 18), url: "https://example.com/ch3-keynote")
                 ]),
            make(.workshop, "Workshop de WidgetKit",
                 day(4, hour: 15, minute: 30),
                 "Introdução a **WidgetKit**: timelines, providers e App Groups."),
            make(.bridge, "Bridge · Design e Tecnologia",
                 day(6, hour: 14),
                 "Alinhamento entre as equipes de design e desenvolvimento.",
                 deliverables: [
                    Deliverable(title: "Protótipo", dueDate: day(8, hour: 12), url: "https://example.com/proto")
                 ]),
            make(.presentation, "App Review",
                 day(12, hour: 16),
                 "Apresentação dos projetos para mentores e convidados."),
            make(.reflection, "Reflection da Sprint",
                 day(15, hour: 17),
                 "Momento de retrospectiva individual e em grupo.")
        ]
    }
}
