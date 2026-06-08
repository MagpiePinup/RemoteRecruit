//
//  SharedComponents.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import SwiftUI

// MARK: - LoadingView

struct LoadingView: View {
    var message: String = "Loading jobs…"

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "Try Again"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let action {
                Button(actionLabel, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - TagView (employment type badge)

struct TagView: View {
    let label: String
    var color: Color = .accentColor

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - BulletRow

struct BulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Previews

#Preview("Loading") { LoadingView() }
#Preview("Empty") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No Results",
        subtitle: "Try a different search term."
    )
}
#Preview("Tag") { TagView(label: "Full-Time") }
