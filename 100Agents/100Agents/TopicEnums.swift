
import Foundation

enum MainCategory: String, CaseIterable, Identifiable {
    case computerScience = "Computer Science"
    case art = "Art"
    case physics = "Physics"
    case history = "History"
    case biology = "Biology"
    case mathematics = "Mathematics"
    case chemistry = "Chemistry"
    case literature = "Literature"
    case music = "Music"
    case geography = "Geography"

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
