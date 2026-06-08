//
//  JobRepository.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import Foundation

protocol JobRepository {
    /// Fetch the full list of available jobs.
    func fetchJobs(request: JobRequestModel) async throws -> [Job]
    
    // Fetch the full list of local JSON file jobs.
    func fetchJobs() async throws -> [Job]

    /// Fetch a single job by its identifier.
    func fetchJob(id: String) async throws -> Job
}

final class JobRepositoryImp: JobRepository {
    private let networkService: NertworkService
    
    init(networkService: NertworkService) {
        self.networkService = networkService
    }
    
    func fetchJobs(request: JobRequestModel) async throws -> [Job] {
        let response = try await networkService.fetchData(input: request)
        return response.jobs
    }
    
    func fetchJobs() async throws -> [Job] {
        // Simulate realistic network latency so loading states are visible.
        try? await Task.sleep(for: .seconds(3))

        guard let url = Bundle.main.url(forResource: "jobs", withExtension: "json") else {
            throw AppError.notFound
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(JobsResponse.self, from: data)
            return response.jobs
        } catch is DecodingError {
            throw AppError.decodingFailure("Failed to decode jobs data.")
        } catch {
            throw AppError.networkFailure(error.localizedDescription)
        }
    }
    
    func fetchJob(id: String) async throws -> Job {
        let jobs = try await fetchJobs()
        guard let job = jobs.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return job
    }
}

extension JobRepository {
    /// Filter already-fetched jobs by query string.
    /// Applied client-side here because the mock/local JSON has no server-side search.
    /// If replaced with a real API, move filtering to the request parameters.
    func search(jobs: [Job], query: String) -> [Job] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return jobs }
        let q = query.lowercased()
        return jobs.filter {
            $0.title.lowercased().contains(q) ||
            $0.company.name.lowercased().contains(q)
        }
    }
}
