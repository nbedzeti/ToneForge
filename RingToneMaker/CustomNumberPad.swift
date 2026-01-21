//
//  CustomNumberPad.swift
//  RingToneMaker
//
//  Custom number pad with black/green theme
//

import SwiftUI

struct CustomNumberPad: View {
    @Binding var text: String
    let onDone: () -> Void
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [":", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Done button bar
            HStack {
                Spacer()
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
            .background(Color.black.opacity(0.85))
            
            // Instruction label
            VStack(spacing: 4) {
                Text("Format: M:SS")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("Example: 1:25 = 1 min 25 sec")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.85))
            
            Divider()
                .background(Color.green.opacity(0.3))
            
            // Number pad
            VStack(spacing: 1) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                handleButtonPress(button)
                            }) {
                                Text(button)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.85))
                            }
                            .frame(height: 60)
                        }
                    }
                }
            }
            .background(Color.green.opacity(0.1))
        }
        .background(Color.black.opacity(0.85))
    }
    
    private func handleButtonPress(_ button: String) {
        switch button {
        case "⌫":
            if !text.isEmpty {
                text.removeLast()
            }
        case ":":
            // Only allow one colon and only after at least one digit
            if !text.contains(":") && !text.isEmpty {
                text += button
            }
        default:
            // Add digit based on current format
            if !text.contains(":") {
                // Before colon - allow up to 2 digits for minutes
                if text.count < 2 {
                    text += button
                }
            } else {
                // After colon - allow up to 2 digits for seconds
                let parts = text.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let secondsPart = String(parts[1])
                    if secondsPart.count < 2 {
                        text += button
                    }
                } else {
                    // Just added colon, no seconds yet
                    text += button
                }
            }
        }
        print("DEBUG: text is now: '\(text)'")
    }
}

#Preview {
    CustomNumberPad(text: .constant("1:25"), onDone: {})
}
