//
//  EventKind.swift
//  StempCaseStudy  ·  Shared (App + Widget)
//
//  Tipos de evento da Academy. Ícone e cor padrão vêm do EventItem original.
//
import Foundation

enum EventKind: String, Codable, CaseIterable, Identifiable {
    case challenge    = "Challenge"
    case workshop     = "Workshop"
    case presentation = "Apresentação"
    case bridge       = "Bridge"
    case integration  = "Integration"
    case events       = "Eventos"
    case reflection   = "Reflection"

    var id: String { rawValue }

    var defaultIcon: String {
        switch self {
        case .challenge:    return "sparkle.text.clipboard.fill"
        case .workshop:     return "book.and.wrench.fill"
        case .presentation: return "play.tv"
        case .bridge:       return "ruler.fill"
        case .integration:  return "figure.socialdance.circle.fill"
        case .events:       return "apple.logo"
        case .reflection:   return "brain.head.profile.fill"
        }
    }

    var defaultColorHex: String {
        switch self {
        case .challenge:    return "#EF9F27"
        case .workshop:     return "#378ADD"
        case .presentation: return "#7F77DD"
        case .bridge:       return "#1D9E75"
        case .integration:  return "#639922"
        case .events:       return "#E98049"
        case .reflection:   return "#DF537E"
        }
    }
}
