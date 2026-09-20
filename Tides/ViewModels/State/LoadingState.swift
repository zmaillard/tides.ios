//
//  LoadingState.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
enum LoadingState<T: Equatable> : Equatable {
    case idle
    case loading
    case loaded(T)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var error: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}
