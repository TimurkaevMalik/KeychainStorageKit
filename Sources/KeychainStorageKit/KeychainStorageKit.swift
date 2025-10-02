import Foundation
import LoggingKit
import Valet

public protocol KeychainStorageProtocol {
    typealias CustomError = KeychainServiceError
    func set<T: Encodable>(_ value: T, forKey key: String) throws(CustomError)
    func loadValue<T: Decodable>(forKey key: String) throws(CustomError) -> T?
    func removeObject(forKey key: String) throws(CustomError)
    func removeAll() throws(CustomError)
}

public final class ValetStorage: KeychainStorageProtocol {
    
    private let logger: LoggerProtocol?
    private let valet: Valet
    
    public init?(
        id: String,
        accessibility: KeychainAccessibility,
        logger: LoggerProtocol?
    ) {
        self.logger = logger
        if let identifier = Identifier(nonEmpty: id) {
            self.valet = Valet.valet(with: identifier, accessibility: accessibility.valetValue)
        } else {
            return nil
        }
    }
    
    public func set<T: Encodable>(_ value: T, forKey key: String) throws(CustomError) {
        do {
            let data = try JSONEncoder().encode(value)
            try valet.setObject(data, forKey: key)
        } catch {
            if let mappedError = map(error: error) {
                throw mappedError
            }
        }
    }
    
    public func loadValue<T: Decodable>(forKey key: String) throws(CustomError) -> T? {
        
        do {
            let data = try valet.object(forKey: key)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let mappedError = map(error: error) {
                throw mappedError
            } else {
                return nil
            }
        }
    }
    
    public func removeObject(forKey key: String) throws(CustomError) {
        do {
            try valet.removeObject(forKey: key)
        } catch {
            if let mappedError = map(error: error) {
                throw mappedError
            }
        }
    }
    
    public func removeAll() throws(CustomError) {
        do {
            try valet.removeAllObjects()
        } catch {
            if let mappedError = map(error: error) {
                throw mappedError
            }
        }
    }
}

private extension ValetStorage {
    func map(error: Error) -> CustomError? {
        if let error = error as? KeychainError {
            
            switch error {
                
            case .itemNotFound, .emptyValue:
                return nil
                
            case .emptyKey:
                logger?.error("Keychain: empty key. Programmer error: \(error)")
                return .underlying(error)
                
                // Нет прав/доступа к связке (entitlements/iCloud/off) → фатально
            case .couldNotAccessKeychain, .missingEntitlement, .userCancelled:
                logger?.error("Keychain access failed. Error: \(error)")
                return .underlying(error)
                
            }
        } else {
            return .underlying(error)
        }
    }
}
