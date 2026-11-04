//
//  EventItem.swift
//  StempCaseStudy
//
//  Idêntico ao EventItem original. Único acréscimo: `onDelete` (menu de
//  contexto) para remover desafios fictícios criados no estudo de caso.
//
import SwiftUI

struct EventItem: View {
    let eventInfos: EventDetail
    let isNew: Bool
    let openEventDetail: () -> Void
    var onDelete: (() -> Void)? = nil

    @State private var showDetail = false
    @State private var opacity: Bool = false

    var body: some View {
        HStack {
            Rectangle()
                .foregroundStyle(Color(hex: eventInfos.colorHex))
                .frame(width: 7)
            VStack(alignment: .leading) {
                Text(eventInfos.typeEvent)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text(eventInfos.formattedDateTime)
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(.leading, 5)
            Spacer()
            Image(systemName: eventInfos.icon)
                .font(.title)
                .symbolRenderingMode(.monochrome)
                .symbolEffect(.wiggle, options: .nonRepeating)
                .foregroundStyle(Color(hex: eventInfos.colorHex))
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundStyle(Color.white.opacity(0.5))
                .padding(.leading, 10)
        }
        .overlay(alignment: .topTrailing) {
            if isNew {
                Text("Novo")
                    .bold()
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .opacity(opacity ? 1 : 0.4)
                    .clipShape(Capsule())
                    .offset(y: -28.5)
                    .animation(
                        .easeOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: opacity
                    )
            }
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.bg900)
        )
        .padding(.horizontal, 5)
        .contentShape(Rectangle())
        .onAppear {
            opacity = true
        }
        .onTapGesture {
            showDetail = true
            openEventDetail()
        }
        .contextMenu {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Remover desafio", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            EventDetailSheet(event: eventInfos)
        }
    }
}

#Preview {
    ZStack {
        Color.bg950.ignoresSafeArea()
        VStack(spacing: 20) {
            ForEach(Array(SampleData.events().prefix(3).enumerated()), id: \.offset) { index, event in
                EventItem(eventInfos: event, isNew: index % 2 == 0) {}
            }
        }
    }
}
