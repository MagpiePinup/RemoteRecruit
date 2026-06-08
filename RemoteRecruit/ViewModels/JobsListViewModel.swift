//
//  JobsListViewModel.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import Foundation
import Observation
import Combine

@MainActor
final class JobsListViewModel: ObservableObject {

    @Published private(set) var state: ViewState<[Job]> = .idle
    @Published var searchQuery: String = ""

    private let service: JobRepository
    private var allJobs: [Job] = []
    private var cancellables = Set<AnyCancellable>()

    init(service: JobRepository) {
        self.service = service
        setupSearchDebounce()
    }

    /// Called on view appear and on pull-to-refresh.
    func loadJobs() async {
        state = .loading
        do {
            let jobs = try await service.fetchJobs()
            allJobs = jobs
            applySearch(query: searchQuery)
        } catch let error as AppError {
            state = .error(error)
        } catch {
            state = .error(.unknown(error.localizedDescription))
        }
    }

    /// Wire up a debounced search publisher so filtering happens
    /// 300 ms after the user stops typing — preventing UI jank on every keystroke.
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                // Only filter if we already have data.
                if !self.allJobs.isEmpty {
                    self.applySearch(query: query)
                }
            }
            .store(in: &cancellables)
    }

    /// Apply search filter and update `state` accordingly.
    private func applySearch(query: String) {
        let filtered = service.search(jobs: allJobs, query: query)
        if filtered.isEmpty {
            state = .empty
        } else {
            state = .loaded(filtered)
        }
    }
}
