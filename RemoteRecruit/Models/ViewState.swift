//
//  ViewState.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 08/06/26.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(AppError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var loadedValue: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var errorValue: AppError? {
        if case .error(let err) = self { return err }
        return nil
    }

    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
