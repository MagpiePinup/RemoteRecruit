//
//  JobCardView.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import SwiftUI

struct JobCardView: View {
    let job: Job

    /// Colour-code employment type badges so they're scannable at a glance.
    private var badgeColor: Color {
        switch job.employmentType {
        case .fullTime:   return .blue
        case .partTime:   return .orange
        case .contract:   return .purple
        case .internship: return .green
        case .freelance:  return .pink
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top row: company + remote badge
            HStack(alignment: .top) {
                // Company avatar placeholder (first letter)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Text(String(job.company.name.prefix(1)))
                        .font(.headline.bold())
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(job.company.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(job.company.industry)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if job.isRemote {
                    TagView(label: "Remote", color: .green)
                }
            }

            // Job title
            Text(job.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            // Location + salary row
            HStack(spacing: 16) {
                Label(job.location.displayString, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(job.salary.displayString)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            // Bottom: employment type + posted date
            HStack {
                TagView(label: job.employmentType.rawValue, color: badgeColor)
                Spacer()
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    JobCardView(job: .preview)
        .padding()
}

extension Job {
    static var preview: Job {
        Job(
            id: "preview",
            title: "Senior iOS Engineer",
            company: .init(
                name: "Acme Corp",
                logoURL: nil,
                industry: "SaaS",
                size: "200-500 employees",
                about: "A great company.",
                website: "https://acme.com"
            ),
            location: .init(city: "San Francisco", state: "Ca", country: "USA"),
            salary: .init(min: 150000, max: 200000, currency: "USD"),
            description: "Build amazing iOS apps.",
            requirements: ["Swift", "SwiftUI"],
            employmentType: .fullTime,
            isRemote: true
        )
    }
}
