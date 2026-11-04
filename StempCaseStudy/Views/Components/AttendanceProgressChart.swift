//
//  AttendanceProgressChart.swift
//  StempCaseStudy
//
//  Idêntico ao AttendanceProgressChart original.
//
import SwiftUI

struct AttendanceProgressChart: View {

    let presences: Int
    let absences: Int
    let delays: Int
    var startDate: Date? = nil

    @State private var animatedPresences: Double = 0
    @State private var animatedDelays: Double = 0
    @State private var animatedAbsences: Double = 0
    @State private var cardsVisible = false

    private var total: Int { presences + absences + delays }

    private func pct(_ v: Double) -> Double {
        guard total > 0 else { return 0 }
        return v / Double(total)
    }

    private var rows: [(String, Double, Color)] {[
        ("Presenças", animatedPresences, Color(hex: "#1D9E75")),
        ("Atrasos", animatedDelays, Color(hex: "#EF9F27")),
        ("Faltas", animatedAbsences, Color(hex: "#D85A30"))
    ]}

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Frequência")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.white)
                    if let start = startDate {
                        Text("\(start.formatted(.dateTime.day().month(.abbreviated).year())) — Hoje")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.35))
                    }
                }
                Spacer()
                Text("\(total) registros")
                    .font(.caption)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Capsule())
                    .foregroundColor(.white.opacity(0.45))
            }

            VStack(spacing: 20) {
                ForEach(rows, id: \.0) { label, animated, color in
                    VStack(spacing: 7) {
                        HStack(alignment: .lastTextBaseline) {
                            Text(label)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.55))
                            Spacer()
                            Text(total > 0 ? "\(Int(pct(animated) * 100))%" : "0%")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.35))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(Color.white.opacity(0.07))
                                    .frame(height: 10)
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(color)
                                    .frame(width: geo.size.width * pct(animated), height: 10)
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }

            Divider().overlay(Color.white.opacity(0.07))

            HStack(spacing: 8) {
                ForEach(Array([
                    ("Presenças", presences, Color(hex: "#1D9E75")),
                    ("Atrasos", delays, Color(hex: "#EF9F27")),
                    ("Faltas", absences, Color(hex: "#D85A30")),
                    ("Total", total, Color.white.opacity(0.6))
                ].enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 3) {
                        Text("\(item.1)")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(item.2)
                        Text(item.0)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .opacity(cardsVisible ? 1 : 0)
                    .offset(y: cardsVisible ? 0 : 8)
                    .animation(
                        .easeOut(duration: 0.5).delay(0.7 + Double(index) * 0.12),
                        value: cardsVisible
                    )
                }
            }
        }
        .padding()
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1)) {
                animatedPresences = Double(presences)
                animatedDelays = Double(delays)
                animatedAbsences = Double(absences)
            }
            cardsVisible = true
        }
    }
}

#Preview {
    ZStack {
        Color.bg900.ignoresSafeArea()
        AttendanceProgressChart(presences: 140, absences: 3, delays: 17)
    }
}
