//
//  AppError.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case networkFailure(String)
    case decodingFailure(String)
    case notFound
    case unknown(String)
    
    /// Typed errors surfaced all the way to the UI.
    var errorDescription: String {
        switch self {
        case .networkFailure(let msg):  return "Network error: \(msg)"
        case .decodingFailure(let msg): return "Data error: \(msg)"
        case .notFound:                 return "The requested resource was not found."
        case .unknown(let msg):         return "Something went wrong: \(msg)"
        }
    }
    
    /// User-facing title for alert dialogs
    var title: String {
        switch self {
        case .networkFailure:  return "Connection Problem"
        case .decodingFailure: return "Data Problem"
        case .notFound:        return "Not Found"
        case .unknown:         return "Error"
        }
    }
}
