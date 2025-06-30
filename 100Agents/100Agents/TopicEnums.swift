
import Foundation

enum MainCategory: String, CaseIterable, Identifiable {
    case computerScience = "Computer Science"
    case art = "Art"
    case physics = "Physics"
    case history = "History"
    case biology = "Biology"
    case chemistry = "Chemistry"
    case literature = "Literature"
    case music = "Music"
    case geography = "Geography"
    case mathematics = "Mathematics"

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .computerScience: return "desktopcomputer"
        case .art: return "paintpalette"
        case .physics: return "atom"
        case .history: return "scroll"
        case .biology: return "leaf"
        case .mathematics: return "function"
        case .chemistry: return "testtube.2"
        case .literature: return "book"
        case .music: return "guitars"
        case .geography: return "map"
        }
    }

    var subTopicKey: String {
        switch self {
        case .computerScience: return "Software"
        default: return self.rawValue
        }
    }
}

enum SubTopic: String, CaseIterable, Identifiable {
    // Computer Science
    case artificialIntelligence = "Artificial Intelligence"
    case machineLearning = "Machine Learning"
    case webDevelopment = "Web Development"
    case mobileAppDevelopment = "Mobile App Development"
    case cybersecurity = "Cybersecurity"
    case dataStructuresAlgorithms = "Data Structures & Algorithms"

    // Art
    case renaissanceArt = "Renaissance Art"
    case impressionism = "Impressionism"
    case modernArt = "Modern Art"
    case digitalArt = "Digital Art"
    case sculpture = "Sculpture"
    case photography = "Photography"

    // Physics
    case quantumMechanics = "Quantum Mechanics"
    case generalRelativity = "General Relativity"
    case astrophysics = "Astrophysics"
    case thermodynamics = "Thermodynamics"
    case particlePhysics = "Particle Physics"

    // History
    case ancientRome = "Ancient Rome"
    case worldWarII = "World War II"
    case theSilkRoad = "The Silk Road"
    case theColdWar = "The Cold War"
    case ancientEgypt = "Ancient Egypt"

    // Biology
    case genetics = "Genetics"
    case evolutionaryBiology = "Evolutionary Biology"
    case marineBiology = "Marine Biology"
    case botany = "Botany"
    case neuroscience = "Neuroscience"

    // Mathematics
    case calculus = "Calculus"
    case linearAlgebra = "Linear Algebra"
    case numberTheory = "Number Theory"
    case topology = "Topology"

    // Chemistry
    case organicChemistry = "Organic Chemistry"
    case inorganicChemistry = "Inorganic Chemistry"
    case physicalChemistry = "Physical Chemistry"
    case biochemistry = "Biochemistry"

    // Literature
    case shakespeareanTragedies = "Shakespearean Tragedies"
    case modernistPoetry = "Modernist Poetry"
    case postColonialLiterature = "Post-colonial Literature"
    case russianClassics = "Russian Classics"

    // Music
    case classicalMusicTheory = "Classical Music Theory"
    case jazzImprovisation = "Jazz Improvisation"
    case electronicMusicProduction = "Electronic Music Production"
    case historyOfRockAndRoll = "History of Rock & Roll"

    // Geography
    case physicalGeography = "Physical Geography"
    case humanGeography = "Human Geography"
    case geopolitics = "Geopolitics"
    case cartography = "Cartography"

    var id: String { self.rawValue }
}

enum DemoVideo: String, CaseIterable, Identifiable {
    case pythagoreanTheorem = "pythagoreanTheorem"
    case quadraticFunction = "quadraticFunction"
    case unitCircle = "unitCircle"
    case surfacePlot = "surfacePlot"
    case sphereVolume = "sphereVolume"
    case cubeSurfaceArea = "cubeSurfaceArea"
    case derivatives = "derivatives"
    case matrixOperations = "matrixOperations"
    case eigenvalues = "eigenvalues"
    case complexNumbers = "complexNumbers"
    
    var id: String { self.rawValue }
    
    var prompt: String {
        switch self {
        case .pythagoreanTheorem:
            return "Demonstrate the Pythagorean theorem with animated triangle and squares"
        case .quadraticFunction:
            return "Visualize a quadratic function and its properties with animation"
        case .unitCircle:
            return "Show how sine and cosine are related on the unit circle with animated angle"
        case .surfacePlot:
            return "Create a 3D surface plot showing z = x^2 + y^2"
        case .sphereVolume:
            return "Calculate and visualize the volume of a sphere with radius r"
        case .cubeSurfaceArea:
            return "Show how to find the surface area of a cube with animations"
        case .derivatives:
            return "Visualize derivatives as the slope of a tangent line"
        case .matrixOperations:
            return "Demonstrate matrix operations with animated transformations"
        case .eigenvalues:
            return "Visualize eigenvalues and eigenvectors of a 2x2 matrix"
        case .complexNumbers:
            return "Show how complex numbers multiply using rotation and scaling"
        }
    }
    
    // Define learning flows with next/previous relationships
    var next: DemoVideo? {
        switch self {
        case .pythagoreanTheorem:
            return .derivatives
        case .derivatives:
            return .quadraticFunction
        case .quadraticFunction:
            return .unitCircle
        case .unitCircle:
            return .surfacePlot
        case .surfacePlot:
            return .sphereVolume
        case .sphereVolume:
            return .cubeSurfaceArea
        case .cubeSurfaceArea:
            return .matrixOperations
        case .matrixOperations:
            return .eigenvalues
        case .eigenvalues:
            return .complexNumbers
        case .complexNumbers:
            return nil // End of flow
        }
    }
    
    var previous: DemoVideo? {
        switch self {
        case .pythagoreanTheorem:
            return nil // Start of flow
        case .derivatives:
            return .pythagoreanTheorem
        case .quadraticFunction:
            return .derivatives
        case .unitCircle:
            return .quadraticFunction
        case .surfacePlot:
            return .unitCircle
        case .sphereVolume:
            return .surfacePlot
        case .cubeSurfaceArea:
            return .sphereVolume
        case .matrixOperations:
            return .cubeSurfaceArea
        case .eigenvalues:
            return .matrixOperations
        case .complexNumbers:
            return .eigenvalues
        }
    }
    
    // Get formatted title for display
    var displayTitle: String {
        switch self {
        case .pythagoreanTheorem:
            return "Pythagorean Theorem"
        case .quadraticFunction:
            return "Quadratic Functions"
        case .unitCircle:
            return "Unit Circle"
        case .surfacePlot:
            return "3D Surface Plots"
        case .sphereVolume:
            return "Sphere Volume"
        case .cubeSurfaceArea:
            return "Cube Surface Area"
        case .derivatives:
            return "Understanding Derivatives"
        case .matrixOperations:
            return "Matrix Operations"
        case .eigenvalues:
            return "Eigenvalues & Eigenvectors"
        case .complexNumbers:
            return "Complex Numbers"
        }
    }
}
