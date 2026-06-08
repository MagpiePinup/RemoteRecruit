//
//  JobDetailViewModel.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Foundation
import Observation
import Combine

/// ViewModel for the Job Detail screen.
/// Receives a `jobId` and resolves the full job object from the service.
///
/// Why pass an id rather than the full Job object?
/// - Deep-link / push notification support: you may arrive on this screen
///   knowing only the job id, without having loaded the list first.
/// - Consistent with how a real API would work (GET /jobs/:id).
/// - The list already has the data, so the service's in-memory fetch is instant.

@MainActor
final class JobDetailViewModel: ObservableObject  {

    @Published private(set) var state: ViewState<Job> = .idle

    private let jobId: String
    private let service: JobRepository

    init(jobId: String, service: JobRepository) {
        self.jobId = jobId
        self.service = service
    }

    func loadJob() async {
        state = .loading
        do {
            let job = try await service.fetchJob(id: jobId)
            state = .loaded(job)
        } catch let error as AppError {
            state = .error(error)
        } catch {
            state = .error(.unknown(error.localizedDescription))
        }
    }
}
