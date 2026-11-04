//
//  EventDetailSheet.swift
//  StempCaseStudy
//
//  Mesmo layout do original: Header, Descrição, Material de Apoio e
//  Links de Entrega (agora vindos da lista estruturada de entregáveis).
//
import SwiftUI

struct EventDetailSheet: View {
    let event: EventDetail
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bg950.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: event.colorHex).opacity(0.15))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: event.icon)
                                        .font(.system(size: 24))
                                        .symbolRenderingMode(.monochrome)
                                        .symbolEffect(.wiggle, options: .nonRepeating)
                                        .foregroundColor(Color(hex: event.colorHex))
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.name)
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(event.formattedDateTime)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        // Descrição
                        if let desc = event.description, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Descrição", systemImage: "text.alignleft")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                                Text(descAttributed(from: desc))
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineSpacing(4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }

                        // Material de Apoio
                        if !event.supportMaterial.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Material de Apoio", systemImage: "folder")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                                ForEach(event.supportMaterial) { item in
                                    AttachmentRow(
                                        filename: item.filename,
                                        url: item.url,
                                        color: Color(hex: event.colorHex)
                                    )
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }

                        // Links de Entrega
                        if !event.deliverables.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Links de Entrega", systemImage: "arrow.up.doc")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                                ForEach(event.deliverables) { item in
                                    LinksRow(
                                        deliverable: item,
                                        color: Color(hex: event.colorHex)
                                    )
                                    if item.id != event.deliverables.last?.id {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(height: 2)
                                            .foregroundStyle(Color.white.opacity(0.06))
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func descAttributed(from raw: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: raw, options: options)) ?? AttributedString(raw)
    }
}

// MARK: - Rows

struct LinksRow: View {
    let deliverable: Deliverable
    let color: Color

    var body: some View {
        if let link = URL(string: deliverable.url), !deliverable.url.isEmpty {
            Link(destination: link) { content }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Text(deliverable.title)
                    .font(.headline)
                    .foregroundColor(color)
                    .lineLimit(1)
                Spacer()
                Text("Entrega: \(deliverable.formattedDueDate)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
            }
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text("Link do entregável")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.vertical, 6)
    }
}

struct AttachmentRow: View {
    let filename: String
    let url: String
    let color: Color

    var body: some View {
        if let link = URL(string: url), !url.isEmpty {
            Link(destination: link) { content }
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(filename)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    EventDetailSheet(event: SampleData.events()[0])
}
