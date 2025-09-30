//
//  Untitled.swift
//  KeychainStorageKit
//
//  Created by Malik Timurkaev on 01.10.2025.
//

import Foundation

public enum KeychainServiceError: Error {
    case notFound
    case encodingFailed(Error)
    case decodingFailed(Error)
    case underlying(Error)
}
