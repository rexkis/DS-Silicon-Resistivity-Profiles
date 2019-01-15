//
//  ErrorManager.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 21/11/2018.
//  Copyright © 2018 Igor Kutovoy. All rights reserved.
//

import Foundation
import Cocoa

enum AppErrors: Error {
    case notConvertible
    case noSolution
    case outOfRangeRes
    case outOfRangeDD
}

extension AppErrors: CustomStringConvertible {
    var description: String {
        switch self {
        case .notConvertible: return "Some field/fields are empty or input value/values cannot be converted to Double! \n Re-Enter with valid Resistivity data, please!"
        case .noSolution: return "Custom resistivity profile cannot be achieved: solution has incorrect Dopant Density values. \n \n Re-Enter with valid Resistivity data, please!"
        case .outOfRangeRes: return "Some field/fields contain Resistivity values out of allowed range: 0.01 - 100 Ohm・cm. \n Re-Enter with valid Resistivity data, please!"
        case .outOfRangeDD: return "Some field/fields contain Dopant Density values out of allowed range: 1e15 - 1e19 at/cm3. \n Re-Enter with valid Dopant Densities data, please!"
        }
    }
}

