//
//  Errors.swift
//  
//
//  Created by Jakub Dolejs on 23/06/2025.
//

import Foundation

public enum ImageProcessingError: LocalizedError {
    case imageConversionFailed
    
    public var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return NSLocalizedString("Image conversion failed", comment: "")
        }
    }
}
