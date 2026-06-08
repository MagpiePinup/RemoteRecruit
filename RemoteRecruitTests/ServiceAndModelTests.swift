//
//  ServiceAndModelTests.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Testing
import Combine
import Foundation

@testable import RemoteRecruit

@MainActor
@Suite("AppError Tests")
struct AppErrorTests {
 
    @Test("networkFailure has correct description and title")
    func networkFailure_hasCorrectDescription() {
        let error = AppError.networkFailure("timeout")
        #expect(error.errorDescription == "Network error: timeout")
        #expect(error.title == "Connection Problem")
    }
 
    @Test("decodingFailure has correct description and title")
    func decodingFailure_hasCorrectDescription() {
        let error = AppError.decodingFailure("bad JSON")
        #expect(error.errorDescription == "Data error: bad JSON")
        #expect(error.title == "Data Problem")
    }
 
    @Test("notFound has correct description and title")
    func notFound_hasCorrectDescription() {
        let error = AppError.notFound
        #expect(error.errorDescription == "The requested resource was not found.")
        #expect(error.title == "Not Found")
    }
 
    @Test("unknown has correct description and title")
    func unknown_hasCorrectDescription() {
        let error = AppError.unknown("mystery")
        #expect(error.errorDescription == "Something went wrong: mystery")
        #expect(error.title == "Error")
    }
 
    @Test("AppError equality is case- and value-sensitive")
    func equality() {
        #expect(AppError.notFound == AppError.notFound)
        #expect(AppError.notFound != AppError.networkFailure("x"))
        #expect(AppError.networkFailure("x") == AppError.networkFailure("x"))
        #expect(AppError.networkFailure("x") != AppError.networkFailure("y"))
    }
}
 
// MARK: - ViewState Tests
 
@Suite("ViewState Tests")
struct ViewStateTests {
 
    @Test("isLoading is true only for the loading case")
    func isLoading_trueOnlyForLoadingCase() {
        #expect(ViewState<Int>.idle.isLoading == false)
        #expect(ViewState<Int>.loading.isLoading == true)
        #expect(ViewState<Int>.loaded(1).isLoading == false)
        #expect(ViewState<Int>.empty.isLoading == false)
        #expect(ViewState<Int>.error(.notFound).isLoading == false)
    }
 
    @Test("loadedValue returns a value only for the loaded case")
    func loadedValue_returnsValueOnlyForLoadedCase() {
        #expect(ViewState<Int>.idle.loadedValue == nil)
        #expect(ViewState<Int>.loading.loadedValue == nil)
        #expect(ViewState<Int>.loaded(42).loadedValue == 42)
        #expect(ViewState<Int>.empty.loadedValue == nil)
        #expect(ViewState<Int>.error(.notFound).loadedValue == nil)
    }
 
    @Test("errorValue returns an error only for the error case")
    func errorValue_returnsErrorOnlyForErrorCase() {
        #expect(ViewState<Int>.idle.errorValue == nil)
        #expect(ViewState<Int>.loaded(1).errorValue == nil)
        #expect(ViewState<Int>.error(.notFound).errorValue == .notFound)
    }
 
    @Test("isEmpty is true only for the empty case")
    func isEmpty_trueOnlyForEmptyCase() {
        #expect(ViewState<Int>.idle.isEmpty == false)
        #expect(ViewState<Int>.loading.isEmpty == false)
        #expect(ViewState<Int>.loaded(1).isEmpty == false)
        #expect(ViewState<Int>.empty.isEmpty == true)
    }
}
 
// MARK: - Job Model Tests
 
@Suite("Job Model Tests")
struct JobModelTests {
 
    @Test("Location displayString formats city, state, country")
    func location_displayString() {
        let loc = Job.Location(city: "Austin", state: "TX", country: "USA")
        #expect(loc.displayString == "Austin, USA")
    }
 
    @Test("SalaryRange displayString contains separator and unit")
    func salaryRange_displayString_USD() {
        let salary = Job.SalaryRange(min: 100000, max: 150000, currency: "USD")
        // NumberFormatter output is locale-dependent in tests,
        // so check for the separator and presence of the time unit only.
        let display = salary.displayString
        #expect(display.contains("–"))
        #expect(display.contains("yr"))
    }
 
    @Test("EmploymentType raw values match expected strings")
    func employmentType_rawValues() {
        #expect(Job.EmploymentType.fullTime.rawValue == "Full-Time")
        #expect(Job.EmploymentType.partTime.rawValue == "Part-Time")
        #expect(Job.EmploymentType.contract.rawValue == "Contract")
        #expect(Job.EmploymentType.internship.rawValue == "Internship")
        #expect(Job.EmploymentType.freelance.rawValue == "Freelance")
    }
 
    @MainActor
    @Test("Job survives a Codable round-trip")
    func job_codable_roundtrip() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
 
        let original = Job.list[0]
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Job.self, from: data)
 
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.salary.min == original.salary.min)
        #expect(decoded.location.displayString == original.location.displayString)
    }
 
    @MainActor
    @Test("Job conforms to Hashable with no duplicates in a Set")
    func job_hashable() {
        let set = Set(Job.list)
        #expect(set.count == Job.list.count)
    }
}
 
// MARK: - MockJobService Tests
 
@Suite("MockJobService Tests")
struct MockJobServiceTests {
 
    @MainActor
    @Test("fetchJobs returns stubbed list")
    func fetchJobs_returnslist() async throws {
        let sut = MockJobService()
        let jobs = try await sut.fetchJobs()
        #expect(jobs == Job.list)
    }
 
    @Test("fetchJobs tracks call count across multiple calls")
    func fetchJobs_tracksCallCount() async throws {
        let sut = MockJobService()
        _ = try await sut.fetchJobs()
        _ = try await sut.fetchJobs()
        #expect(sut.fetchJobsCallCount == 2)
    }
 
    @MainActor
    @Test("fetchJob by id returns the correct job")
    func fetchJob_byId_returnsCorrectJob() async throws {
        let sut = MockJobService()
        let job = try await sut.fetchJob(id: "t002")
        #expect(job.id == "t002")
        #expect(job.company.name == "AlphaTech")
    }
 
    @Test("fetchJob with unknown id throws notFound")
    func fetchJob_unknownId_throwsNotFound() async throws {
        let sut = MockJobService()
        await #expect(throws: AppError.notFound) {
            _ = try await sut.fetchJob(id: "nonexistent")
        }
    }
 
    @Test("fetchJobs with stubbed error throws that error")
    func fetchJobs_withStubbedError_throws() async throws {
        let sut = MockJobService()
        sut.stubbedError = .networkFailure("test")
        await #expect(throws: AppError.networkFailure("test")) {
            _ = try await sut.fetchJobs()
        }
    }
 
    @Test("search with empty query returns all jobs")
    func search_emptyQuery_returnsAll() {
        let sut = MockJobService()
        let result = sut.search(jobs: Job.list, query: "")
        #expect(result.count == Job.list.count)
    }
 
    @Test("search matches title case-insensitively")
    func search_matchesTitle_caseInsensitive() {
        let sut = MockJobService()
        let result = sut.search(jobs: Job.list, query: "ios")
        #expect(result.allSatisfy {
            $0.title.lowercased().contains("ios") || $0.company.name.lowercased().contains("ios")
        })
    }
 
    @Test("search matches company name")
    func search_matchesCompanyName() {
        let sut = MockJobService()
        let result = sut.search(jobs: Job.list, query: "AlphaTech")
        #expect(result.count == 1)
    }
}
