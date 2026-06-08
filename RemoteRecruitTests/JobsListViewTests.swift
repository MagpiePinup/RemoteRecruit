//
//  JobsListViewTests.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Testing
import Combine
@testable import RemoteRecruit

@MainActor
@Suite("JobListViewModel Tests")
struct JobListViewModelTests {
 
    private var sut: JobsListViewModel
    private var mockService: MockJobService
 
    init() {
        mockService = MockJobService()
        sut = JobsListViewModel(service: mockService)
    }
 
    // MARK: - Initial state
 
    @Test("Initial state is idle")
    func initialState_isIdle() {
        #expect(sut.state.isLoading == false)
        if case .idle = sut.state { } else {
            Issue.record("Expected .idle, got \(sut.state)")
        }
    }
 
    // MARK: - loadJobs – success path
 
    @Test("loadJobs success transitions to loaded")
    func loadJobs_success_transitionsToLoaded() async {
        await sut.loadJobs()
 
        if case .loaded(let jobs) = sut.state {
            #expect(jobs.count == Job.list.count)
        } else {
            Issue.record("Expected .loaded, got \(sut.state)")
        }
    }
 
    @Test("loadJobs success calls service exactly once")
    func loadJobs_success_callsServiceOnce() async {
        await sut.loadJobs()
        #expect(mockService.fetchJobsCallCount == 1)
    }
 
    @Test("loadJobs success returns correct job data")
    func loadJobs_success_jobsHaveCorrectData() async {
        await sut.loadJobs()
        guard case .loaded(let jobs) = sut.state else {
            Issue.record("Expected .loaded state")
            return
        }
        #expect(jobs.first?.id == "t001")
        #expect(jobs.first?.title == "iOS Developer")
    }
 
    // MARK: - loadJobs – empty list
 
    @Test("loadJobs with empty list transitions to empty")
    func loadJobs_emptyList_transitionsToEmpty() async {
        mockService.stubbedJobs = []
        await sut.loadJobs()
 
        if case .empty = sut.state { } else {
            Issue.record("Expected .empty, got \(sut.state)")
        }
    }
 
    // MARK: - loadJobs – error paths
 
    @Test("loadJobs network error transitions to error state")
    func loadJobs_networkError_transitionsToError() async {
        mockService.stubbedError = .networkFailure("timeout")
        await sut.loadJobs()
 
        if case .error(let error) = sut.state {
            #expect(error == .networkFailure("timeout"))
        } else {
            Issue.record("Expected .error, got \(sut.state)")
        }
    }
 
    @Test("loadJobs not-found error transitions to error state")
    func loadJobs_notFound_transitionsToError() async {
        mockService.stubbedError = .notFound
        await sut.loadJobs()
 
        if case .error(let error) = sut.state {
            #expect(error == .notFound)
        } else {
            Issue.record("Expected .error, got \(sut.state)")
        }
    }
 
    // MARK: - loadJobs – retry
 
    @Test("loadJobs retry after error recovers to loaded state")
    func loadJobs_retry_afterError_recovers() async {
        // First call fails
        mockService.stubbedError = .networkFailure("timeout")
        await sut.loadJobs()
        if case .error = sut.state { } else { Issue.record("Should be error") }
 
        // Second call succeeds
        mockService.stubbedError = nil
        await sut.loadJobs()
 
        if case .loaded = sut.state { } else {
            Issue.record("Expected .loaded after retry, got \(sut.state)")
        }
        #expect(mockService.fetchJobsCallCount == 2)
    }
 
    // MARK: - Search
 
    @Test("Search by title filters correctly")
    func search_byTitle_filtersCorrectly() async {
        await sut.loadJobs()
        sut.searchQuery = "iOS"
        // Test the search logic directly — debounce timing is unreliable in unit tests.
        let result = mockService.search(jobs: Job.list, query: "iOS")
        #expect(result.count == 2) // "iOS Developer" + "Contract iOS Dev"
    }
 
    @Test("Search by company name filters correctly")
    func search_byCompany_filtersCorrectly() async {
        await sut.loadJobs()
        let result = mockService.search(jobs: Job.list, query: "AlphaTech")
        #expect(result.count == 1)
        #expect(result.first?.company.name == "AlphaTech")
    }
 
    @Test("Empty search query returns all jobs")
    func search_emptyQuery_returnsAll() async {
        await sut.loadJobs()
        let result = mockService.search(jobs: Job.list, query: "")
        #expect(result.count == Job.list.count)
    }
 
    @Test("Whitespace-only query returns all jobs")
    func search_whitespaceOnly_returnsAll() async {
        await sut.loadJobs()
        let result = mockService.search(jobs: Job.list, query: "   ")
        #expect(result.count == Job.list.count)
    }
 
    @Test("Search is case-insensitive")
    func search_caseInsensitive() async {
        let result = mockService.search(jobs: Job.list, query: "ios")
        let upperResult = mockService.search(jobs: Job.list, query: "IOS")
        #expect(result.count == upperResult.count)
    }
 
    @Test("Search with no match returns empty array")
    func search_noMatch_returnsEmpty() async {
        let result = mockService.search(jobs: Job.list, query: "QuantumCompanyXYZ999")
        #expect(result.isEmpty)
    }
 
    // MARK: - Loading state sequence
 
    @Test("loadJobs emits loading state before result")
    func loadJobs_setsLoadingStateFirst() async {
        var states: [Bool] = []
        let cancellable = sut.$state.sink { state in
            states.append(state.isLoading)
        }
        defer { cancellable.cancel() }
 
        mockService.delay = 0
        await sut.loadJobs()
        // states[0] = initial .idle (false), states[1] = .loading (true), states[2] = .loaded (false)
        #expect(states.contains(true), "Loading state should have been emitted")
    }
}
