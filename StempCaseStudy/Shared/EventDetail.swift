//
//  EventDetail.swift
//  StempCaseStudy  ·  Shared (App + Widget)
//
//  Mesmo modelo do app original (EventDetail), mas sem Airtable:
//  o que antes era uma string "Título - dd/MM/yyyy - link, ..." agora é
//  uma lista estruturada de entregáveis (mais fácil de usar no Widget).
//
import Foundation

struct SupportMaterial: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var filename: String = ""
    var url: String = ""
}

struct Deliverable: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var title: String = ""
    var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var url: String = ""

    var formattedDueDate: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "dd/MM/yyyy"
        return fmt.string(from: dueDate)
    }
}

struct EventDetail: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let typeEvent: String          // rawValue de EventKind
    let time: Date
    let icon: String               // SF Symbol
    let colorHex: String
    let description: String?
    let supportMaterial: [SupportMaterial]
    let deliverables: [Deliverable]

    init(
        id: String = UUID().uuidString,
        name: String,
        typeEvent: String,
        time: Date,
        icon: String,
        colorHex: String,
        description: String? = nil,
        supportMaterial: [SupportMaterial] = [],
        deliverables: [Deliverable] = []
    ) {
        self.id = id
        self.name = name
        self.typeEvent = typeEvent
        self.time = time
        self.icon = icon
        self.colorHex = colorHex
        self.description = description
        self.supportMaterial = supportMaterial
        self.deliverables = deliverables
    }

    var formattedDateTime: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "d 'de' MMM 'às' HH:mm"
        return fmt.string(from: time)
    }

    var formattedTime: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: time)
    }

    /// Próximo prazo de entrega ainda não vencido (útil para o Widget).
    var nextDeliverable: Deliverable? {
        deliverables
            .filter { $0.dueDate >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.dueDate < $1.dueDate }
            .first
    }
}
