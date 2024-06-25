import ProjectDescription

enum ProjectDescriptor {
    static let name = "REC"
    static let organizationName = "Nikita Semenov"
    static let destinations: Destinations = [.iPad, .iPhone]
    static let bundleId = "com.castlelecs.\(name)"
    static let deploymentTargets: DeploymentTargets = .iOS("16.0")
    static let infoPlist: Path = "Info.plist"
    static let sourcesFolder: [Path] = ["Sources/**"]
    static let resourcesFolder: Path = "Resources/"
}

let mainTarget = Target.target(
    name: ProjectDescriptor.name,
    destinations: ProjectDescriptor.destinations,
    product: .app,
    productName: ProjectDescriptor.name,
    bundleId: ProjectDescriptor.bundleId,
    deploymentTargets: ProjectDescriptor.deploymentTargets,
    infoPlist: .file(path: ProjectDescriptor.infoPlist),
    sources: .paths(ProjectDescriptor.sourcesFolder),
    resources: .resources([.folderReference(path: ProjectDescriptor.resourcesFolder)])
)

let project = Project(
    name: ProjectDescriptor.name,
    // organizationName: ProjectDescriptor.organizationName,
    targets: [
        mainTarget,
    ]
)
