//
//  JobModel.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import Foundation


/// JSON root has a `jobs` key wrapping the array.
struct JobsResponse: Decodable {
    let jobs: [Job]
}

/// The core domain model. Identifiable enables ForEach/List usage.
/// Codable enables decoding from JSON (local mock or real API).
/// Hashable enables Set operations and diffing.
struct Job: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let company: Company
    let location: Location
    let salary: SalaryRange
    let description: String
    let requirements: [String]
    let employmentType: EmploymentType
    let isRemote: Bool

    struct Company: Codable, Hashable {
        let name: String
        let logoURL: String?
        let industry: String
        let size: String        // e.g. "50-200 employees"
        let about: String
        let website: String?
    }

    struct Location: Codable, Hashable {
        let city: String
        let state: String
        let country: String

        var displayString: String {
            "\(city), \(country)"
        }
    }

    struct SalaryRange: Codable, Hashable {
        let min: Int
        let max: Int
        let currency: String

        /// Human-readable representation, e.g. "$80,000 – $120,000 / yr"
        var displayString: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            formatter.maximumFractionDigits = 0
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "\(min)"
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "\(max)"
            return "\(minStr) – \(maxStr) / yr"
        }
    }

    enum EmploymentType: String, Codable, CaseIterable {
        case fullTime   = "Full-Time"
        case partTime   = "Part-Time"
        case contract   = "Contract"
        case internship = "Internship"
        case freelance  = "Freelance"
    }
}

