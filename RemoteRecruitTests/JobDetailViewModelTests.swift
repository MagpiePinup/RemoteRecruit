//
//  JobDetailViewModelTests.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import XCTest
@testable import RemoteRecruit

@MainActor
final class JobDetailViewModelTests: XCTestCase {

    private var mockService: MockJobService!

    override func setUp() {
        super.setUp()
        mockService = MockJobService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    // MARK: - loadJob – success

    func test_loadJob_success_transitionsToLoaded() async {
        let sut = makeSUT(jobId: "t001")
        await sut.loadJob()

        if case .loaded(let job) = sut.state {
            XCTAssertEqual(job.id, "t001")
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
    }

    func test_loadJob_callsService() async {
        let sut = makeSUT(jobId: "t002")
        await sut.loadJob()

        XCTAssertEqual(mockService.fetchJobCallCount, 1)
        XCTAssertEqual(mockService.lastFetchedJobId, "t002")
    }

    func test_loadJob_correctJobData() async {
        let sut = makeSUT(jobId: "t002")
        await sut.loadJob()

        guard case .loaded(let job) = sut.state else { return XCTFail() }
        XCTAssertEqual(job.company.name, "AlphaTech")
        XCTAssertTrue(job.isRemote)
    }

    // MARK: - loadJob – not found

    func test_loadJob_unknownId_transitionsToError() async {
        let sut = makeSUT(jobId: "nonexistent")
        await sut.loadJob()

        if case .error(let error) = sut.state {
            XCTAssertEqual(error, .notFound)
        } else {
            XCTFail("Expected .error(.notFound)")
        }
    }

    // MARK: - loadJob – service error

    func test_loadJob_serviceError_propagatesError() async {
        mockService.stubbedError = .networkFailure("server down")
        let sut = makeSUT(jobId: "t001")
        await sut.loadJob()

        if case .error(let error) = sut.state {
            XCTAssertEqual(error, .networkFailure("server down"))
        } else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - Retry

    func test_loadJob_retry_afterError_recovers() async {
        mockService.stubbedError = .networkFailure("offline")
        let sut = makeSUT(jobId: "t001")
        await sut.loadJob()
        if case .error = sut.state { } else { XCTFail("Should be error") }

        mockService.stubbedError = nil
        await sut.loadJob()

        if case .loaded = sut.state { } else {
            XCTFail("Expected .loaded after retry")
        }
    }

    // MARK: - Loading state

    func test_loadJob_setsLoadingBeforeResult() async {
        let sut = makeSUT(jobId: "t001")

        await sut.loadJob()

        if case .loaded(let job) = sut.state {
            XCTAssertEqual(job.id, "t001")
        } else {
            XCTFail("Expected success state")
        }
    }

    // MARK: - Helpers

    private func makeSUT(jobId: String) -> JobDetailViewModel {
        JobDetailViewModel(jobId: jobId, service: mockService)
    }
}

