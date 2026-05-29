import SwiftUI

struct ConfettiPiece: Identifiable {
    let id    = UUID()
    let x:      CGFloat
    let color:  Color
    let size:   CGFloat
    let speed:  Double
    let angle:  Double
    let shape:  Int
    let delay:  Double
}

struct ConfettiView: View {
    let pieces: [ConfettiPiece] = (0..<80).map { _ in
        ConfettiPiece(
            x:     CGFloat.random(in: 0...1),
            color: [
                Color(hex: "F5C842"),
                Color(hex: "185FA5"),
                Color(hex: "4CAF50"),
                Color(hex: "E05555"),
                Color(hex: "C8923A"),
                Color(hex: "A855F7"),
                Color(hex: "EC4899"),
            ].randomElement()!,
            size:  CGFloat.random(in: 8...18),
            speed: Double.random(in: 1.5...3.0),
            angle: Double.random(in: -45...45),
            shape: Int.random(in: 0...2),
            delay: Double.random(in: 0...0.6))
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces) { piece in
                ConfettiFallingPiece(
                    piece:  piece,
                    height: geo.size.height)
                .position(
                    x: piece.x * geo.size.width,
                    y: -20)
            }
        }
    }
}

struct ConfettiFallingPiece: View {
    let piece:  ConfettiPiece
    let height: CGFloat

    @State private var yOffset:  CGFloat = 0
    @State private var rotation: Double  = 0
    @State private var opacity:  Double  = 1

    var body: some View {
        pieceShape
            .frame(width: piece.size, height: piece.size)
            .foregroundColor(piece.color)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + piece.delay) {
                    withAnimation(.easeIn(
                        duration: piece.speed)) {
                        yOffset  = height + 40
                        rotation = Double.random(
                            in: 180...720)
                    }
                    withAnimation(.easeIn(
                        duration: piece.speed * 0.4)
                        .delay(piece.speed * 0.7)) {
                        opacity = 0
                    }
                }
            }
    }

    @ViewBuilder
    var pieceShape: some View {
        switch piece.shape {
        case 0:  Circle()
        case 1:  RoundedRectangle(cornerRadius: 2)
        default: TriangleShape()
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to:    CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}
