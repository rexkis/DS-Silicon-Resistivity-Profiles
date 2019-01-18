//
//  Constants.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Foundation
import Cocoa

typealias DopantParameters = (mWeight:Double,segCf:Double,description:String,color:NSColor,conductivity:String)
typealias DopantsParamDict = [String : DopantParameters]
typealias Distributions = (dopDist:[[Double]], netDist:[[Double]], comp:[Double], resDist:[Double], negRange:[Int], startConductivity:String)

class Constants {
    
    static let g = (0...99).map{Double($0)*0.01}
    static let dopantsDict:DopantsParamDict = [
        "B":(10.811,  0.8,  "Boron",NSColor.blue,"P-type"),
        "P":(30.97376,0.35, "Phosphorus",NSColor.green,"N-type"),
        "Ga":(69.723, 0.008,"Gallium",NSColor.purple,"P-type"),
        "As":(74.9216,0.30, "Arsenic",NSColor.magenta,"N-type"),
        "Al":(26.9815,0.002,"Aluminium",NSColor.cyan,"P-type"),
        "Sn":(118.69, 0.16, "Tin",NSColor.darkGray,"Amphotheric"),
        "Sb":(121.75, 0.23, "Antimony",NSColor.brown,"N-type"),
        "Net":(1.0,   1.0,  "Net Distribution",NSColor.red,""),
        "Res":(1.0,   1.0,  "Resistivity Distribution",NSColor.orange, ""),
        "Cmp":(1.0,   1.0,  "Compensation Level Distribution",NSColor.cyan, "")]
    
    static let dopantProfiles:[String] = ["B + P","P + Ga","B + As","As + Ga","B + P + Ga","B + As + Ga"]
    static let dopantsArray:[[String]] = [["B","P"],["P","Ga"],["B","As"],["As","Ga"],["B","P","Ga"],["B","As","Ga"]]
    
    static let font:NSFont? = NSFont(name: "Helvetica Light", size:12)
    static let fontSuper:NSFont? = NSFont(name: "Helvetica Light", size:8)
}
