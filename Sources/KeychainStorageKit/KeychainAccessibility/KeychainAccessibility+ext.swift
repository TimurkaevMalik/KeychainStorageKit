//
//  Untitled.swift
//  KeychainStorageKit
//
//  Created by Malik Timurkaev on 01.10.2025.
//

import Valet

/// Маппинг нашего уровня доступности на Valet/Keychain.
extension KeychainAccessibility {
    var valetValue: Accessibility {
        switch self {
        case .whenUnlockedThisDeviceOnly:
                .whenUnlockedThisDeviceOnly
        }
    }
}
