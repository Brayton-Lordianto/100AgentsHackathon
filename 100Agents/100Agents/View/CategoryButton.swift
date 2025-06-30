//
//  CapsuleButton.swift
//  100Agents
//
//  Created by Brayton Lordianto on 6/27/25.
//

import SwiftUI

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    let shimmerDuration: TimeInterval = 2
    @State private var shimmerStartTime: Date?
    @State private var isShimmering = false
    
    var buttonView: some View {
        Button(action: {
            action();
            triggerShimmer()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.black)
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color.green.opacity(0.1) : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.green.opacity(0.7) : Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .animation(.spring(), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    let startDate = Date()
    
    var timelineView: some View {
        TimelineView(.animation) { timeline in
            let currentTime = timeline.date.timeIntervalSince(shimmerStartTime ?? Date())
            buttonView
                .visualEffect { content, proxy in
                    content
                        .layerEffect(
                            ShaderLibrary.premium_shimmer(
                                .float(currentTime),
                                .float2(proxy.size),
                                .float(shimmerDuration)
                            ),
                            maxSampleOffset: .zero
                        )
                }
                .clipShape(InsettedCapsule(inset: -1)) // Clip again to ensure shimmer stays within bounds
        }
    }
    
    var body: some View {
        if !isSelected { buttonView }
        else {
            timelineView
        }
    }
    
    private func triggerShimmer() {
        shimmerStartTime = Date()
        isShimmering.toggle()
    }
}

//
//#Preview {
//    BrowseView()
//}

struct InsettedCapsule: Shape {
    let inset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: inset, dy: inset)
        return Capsule().path(in: insetRect)
    }
}
