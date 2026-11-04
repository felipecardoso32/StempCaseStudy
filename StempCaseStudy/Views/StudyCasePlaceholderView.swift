//
//  StudyCasePlaceholderView.swift
//  StempCaseStudy
//
//  Tela vazia usada nas páginas que não fazem parte do recorte.
//
import SwiftUI

struct StudyCasePlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.25))
                Text("Este projeto é para fins de estudo de caso")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Text("Esta página não faz parte do recorte replicado.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
        .navigationTitle(title)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        StudyCasePlaceholderView(title: "Perfil", icon: "person.crop.circle.fill")
    }
}
