//
//  FilterChipView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.teal : Color(.systemGray5))
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        FilterChipView(title: "Beach", isSelected: true, action: {})
        FilterChipView(title: "Mountain", isSelected: false, action: {})
        FilterChipView(title: "City", isSelected: false, action: {})
    }
    .padding()
}
