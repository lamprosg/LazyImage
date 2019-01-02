//
//  LazyImage+Error.swift
//  Pods
//
//  Created by Lampros Giampouras on 02/01/2019.
//

/// LazyImage error object
///
/// - CallFailed: The download request did not succeed.
/// - noDataAvailable: The download request returned nil response.
/// - CorruptedData: The downloaded data are corrupted and can not be read.
public enum LazyImageError: Error {
    case CallFailed
    case noDataAvailable
    case CorruptedData
}

extension LazyImageError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .CallFailed:
            return NSLocalizedString("The download request did not succeed.", comment: "Error")
            
        case .noDataAvailable:
            return NSLocalizedString("The download request returned nil response.", comment: "Error")
            
        case .CorruptedData:
            return NSLocalizedString("The downloaded data are corrupted and can not be read.", comment: "Error")
        }
    }
}
