//
//  MockService.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Foundation
@testable import RemoteRecruit

/// Test double that conforms to `JobServiceProtocol`.
/// Provides fine-grained control for every test scenario:
///   - Success with configurable data
///   - Forced error injection
///   - Call count tracking
///

final class MockJobService: JobRepository {

    var stubbedJobs: [Job] = Job.list

    var stubbedError: AppError? = nil

    var delay: TimeInterval = 0

    private(set) var fetchJobsCallCount = 0
    private(set) var fetchJobCallCount = 0
    private(set) var lastFetchedJobId: String? = nil

    // MARK: - JobServiceProtocol
    
    func fetchJobs(request: JobRequestModel) async throws -> [Job] {
        return stubbedJobs
    }

    func fetchJobs() async throws -> [Job] {
        fetchJobsCallCount += 1
        if delay > 0 {
            try await Task.sleep(for: .seconds(3))
        }
        if let error = stubbedError { throw error }
        return stubbedJobs
    }

    func fetchJob(id: String) async throws -> Job {
        fetchJobCallCount += 1
        lastFetchedJobId = id
        if let error = stubbedError { throw error }
        guard let job = stubbedJobs.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return job
    }
}

// MARK: - Test fixtures

extension Job {
    static var list: [Job] {
        [
            Job(
                id: "t001",
                title: "iOS Developer",
                company: .init(
                    name: "TestCo",
                    logoURL: nil,
                    industry: "Tech",
                    size: "100-500",
                    about: "Test company",
                    website: nil
                ),
                location: .init(city: "Austin", state: "TX", country: "USA"),
                salary: .init(min: 120000, max: 160000, currency: "USD"),
                description: "Build apps.",
                requirements: ["Swift"],
                employmentType: .fullTime,
                isRemote: false
            ),
            Job(
                id: "t002",
                title: "Android Engineer",
                company: .init(
                    name: "AlphaTech",
                    logoURL: nil,
                    industry: "Mobile",
                    size: "50-200",
                    about: "Another test company",
                    website: nil
                ),
                location: .init(city: "Remote", state: "N/A", country: "USA"),
                salary: .init(min: 110000, max: 140000, currency: "USD"),
                description: "Build Android apps.",
                requirements: ["Kotlin"],
                employmentType: .fullTime,
                isRemote: true
            ),
            Job(
                id: "t003",
                title: "Contract iOS Dev",
                company: .init(
                    name: "TestCo",
                    logoURL: nil,
                    industry: "Tech",
                    size: "100-500",
                    about: "Test company",
                    website: nil
                ),
                location: .init(city: "Chicago", state: "IL", country: "USA"),
                salary: .init(min: 90, max: 130, currency: "USD"),
                description: "Contract work.",
                requirements: ["Swift", "UIKit"],
                employmentType: .contract,
                isRemote: false
            )
        ]
    }
}
