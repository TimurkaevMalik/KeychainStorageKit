// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "KeychainStorageKit"
let packageNameDynamic = packageName + "-Dynamic"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v14)],
    products: [
        .library(name: packageName, targets: [packageName]),
        .library(name: packageNameDynamic, type: .dynamic, targets: [packageName]),
    ],
    dependencies: [
        .make(from: SPMDependency.loggingKit),
        .make(from: SPMDependency.valet)
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                .product(SPMDependency.loggingKit.name),
                .product(SPMDependency.valet.name)
            ]
        ),
    ]
)

/// MARK: - Dependencies
fileprivate enum SPMDependency {
    static let valet = PackageModel(
        name: "Valet",
        url: "https://github.com/square/Valet.git",
        requirement: .version(.init(5, 0, 0))
    )
    
    static let loggingKit = PackageModel(
        name: "LoggingKit",
        url: "https://github.com/TimurkaevMalik/LoggingKit.git",
        requirement: .version(.init(1, 3, 0))
    )
}

fileprivate struct PackageModel: Sendable {
    let name: String
    let url: String
    let requirement: Requirement
    
    init(name: String, url: String, requirement: Requirement) {
        self.name = name
        self.url = url
        self.requirement = requirement
    }
    
    public enum Requirement: Sendable{
        case version(Version)
        case branch(String)
        
        var string: String {
            switch self {
                
            case .version(let version):
                return version.stringValue
                
            case .branch(let string):
                return string
            }
        }
    }
}

fileprivate extension Version {
    var stringValue: String {
        let major = "\(major)"
        let minor = "\(minor)"
        let patch = "\(patch)"
        
        return major + "." + minor + "." + patch
    }
    
    init(string: String) {
        self.init(stringLiteral: string)
    }
}

fileprivate extension Package.Dependency {
    static func make(from package: PackageModel) -> Package.Dependency {
        let url = package.url
        let requirement = package.requirement.string
        
        switch package.requirement {
            
        case .version:
            return .package(url: url, from: .init(string: requirement))
        case .branch:
                return .package(url: url, branch: requirement)
        }
    }
}

/// MARK: - Target.Dependency
fileprivate extension Target.Dependency {
    static func product(_ name: String) -> Self {
        .product(name: name, package: name)
    }
}
