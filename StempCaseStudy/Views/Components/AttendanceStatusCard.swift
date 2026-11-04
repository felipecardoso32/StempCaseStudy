//
//  AttendanceStatusCard.swift
//  StempCaseStudy
//
//  Idêntico ao AttendanceStatusCard original.
//
import SwiftUI

struct AttendanceStatusCard: View {
    let status: (label: String, color: Color)
    let absences: Int

    @State private var visible = false
    @State private var pulsing = false

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(status.color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    ZStack {
                        Circle()
                            .fill(status.color.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(pulsing ? 2.2 : 1)
                            .opacity(pulsing ? 0 : 1)
                        Circle()
                            .fill(status.color)
                            .frame(width: 12, height: 12)
                    }
                )
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.4)
                        .repeatForever(autoreverses: false)
                    ) {
                        pulsing = true
                    }
                }
            VStack(alignment: .leading, spacing: 3) {
                Text("Situação atual")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                Text(status.label)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(status.color)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(absences)")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                Text(absences == 1 ? "falta" : "faltas")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                visible = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.bg950.ignoresSafeArea()
        AttendanceStatusCard(status: (label: "Ótimo", color: .green), absences: 0)
            .padding()
    }
}
