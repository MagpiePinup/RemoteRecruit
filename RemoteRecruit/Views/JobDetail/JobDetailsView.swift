//
//  JobDetailsView.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Foundation
import SwiftUI

/// Detail screen for a single job.
/// Receives a `jobId` (not the full Job) to mirror real deep-link/push scenarios.
struct JobDetailView: View {

    @StateObject private var viewModel: JobDetailViewModel

    init(jobId: String, service: JobRepository = JobRepositoryImp(networkService: NertworkServiceImp())) {
        _viewModel = StateObject(
            wrappedValue: JobDetailViewModel(jobId: jobId, service: service)
        )
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear.onAppear { Task { await viewModel.loadJob() } }

            case .loading:
                LoadingView(message: "Loading job details…")

            case .loaded(let job):
                jobDetailContent(job: job)

            case .empty:
                // Shouldn't happen for a single job fetch, but handled for completeness.
                EmptyStateView(
                    icon: "tray",
                    title: "Job Not Found",
                    subtitle: "This job listing may have been removed."
                )

            case .error(let error):
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: error.title,
                    subtitle: error.errorDescription ?? "Please try again.",
                    action: { Task { await viewModel.loadJob() } },
                    actionLabel: "Retry"
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Main content

    @ViewBuilder
    private func jobDetailContent(job: Job) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                headerCard(job: job)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Divider().padding(.vertical, 16)

                Group {
                    SectionHeader(title: "About the Role")
                        .padding(.horizontal, 16)
                    Text(job.description)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                }

                Divider().padding(.vertical, 16)

                companySection(company: job.company)
                    .padding(.horizontal, 16)

                Button {
                    // In a real app: open application flow or deep link
                } label: {
                    Text("Apply Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(job.title)
    }

    // MARK: - Header card

    @ViewBuilder
    private func headerCard(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(alignment: .top, spacing: 14) {
                // Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Text(String(job.company.name.prefix(1)))
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.title3.bold())
                        .lineLimit(2)
                    Text(job.company.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Meta chips
            HStack(spacing: 10) {
                TagView(label: job.employmentType.rawValue)
                if job.isRemote {
                    TagView(label: "Remote", color: .green)
                }
                Spacer()
            }

            Divider()

            // Stats row
            HStack(spacing: 0) {
                metaStat(icon: "mappin.circle", label: "Location", value: job.location.displayString)
                Divider().frame(height: 36)
                metaStat(icon: "banknote", label: "Salary", value: job.salary.displayString)
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private func metaStat(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: - Company section

    @ViewBuilder
    private func companySection(company: Job.Company) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About \(company.name)")

            VStack(alignment: .leading, spacing: 8) {
                Label(company.industry, systemImage: "building.2")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label(company.size, systemImage: "person.2")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let website = company.website {
                    Label(website, systemImage: "link")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                }
            }

            Text(company.about)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.top, 4)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        JobDetailView(jobId: "preview")
    }
}
