//
//  JobListView.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import SwiftUI

/// The root screen of the app.
/// Responsibilities:
///   - Trigger ViewModel to load data on appear
///   - Bind search bar to ViewModel's `searchQuery`
///   - Render the correct child view based on `ViewState`
///   - Navigate to JobDetailView on tap
struct JobListView: View {

    @StateObject private var viewModel: JobsListViewModel

    init(service: JobRepository = JobRepositoryImp(networkService: NertworkServiceImp())) {
        _viewModel = StateObject(wrappedValue: JobsListViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear { Task { await viewModel.loadJobs() } }

                case .loading:
                    LoadingView()

                case .loaded(let jobs):
                    jobList(jobs: jobs)

                case .empty:
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Jobs Found",
                        subtitle: "Try adjusting your search. No results Found."
                    )

                case .error(let error):
                    EmptyStateView(
                        icon: "wifi.exclamationmark",
                        title: error.title,
                        subtitle: error.errorDescription ?? "An unexpected error occurred.",
                        action: { Task { await viewModel.loadJobs() } },
                        actionLabel: "Retry"
                    )
                }
            }
            .navigationTitle("Jobs")
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by title or company"
            )
            .refreshable {
                await viewModel.loadJobs()
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func jobList(jobs: [Job]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Results count hint
                HStack {
                    Text("\(jobs.count) job\(jobs.count == 1 ? "" : "s") found")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)

                ForEach(jobs) { job in
                    NavigationLink(destination: JobDetailView(jobId: job.id)) {
                        JobCardView(job: job)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)  // Remove NavigationLink blue tint
                }
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    JobListView()
}
