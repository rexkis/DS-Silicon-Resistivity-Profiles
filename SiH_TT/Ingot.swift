//
//  Ingot.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 10.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

class Ingot: NSObject {
    
    // Initializing
    var currentDopants:[String]
    var initConcs: [Double]
    
    init(currentDopants:[String], initConcs: [Double]) {
        self.currentDopants = currentDopants
        self.initConcs = initConcs
        super.init()
    }
    
    func getData() -> Distributions {
        // Dopant Densities
        let ddST = DopantsDistribution.sharedInstance
        ddST.currentDopants = currentDopants
        ddST.initC = initConcs
        let dopDistr = ddST.getDopantDistribution()
        
        // Net Density
        let ndST = NetDistribution.sharedInstance
        ndST.currentDopants = currentDopants
        ndST.dopDist = dopDistr
        let netDistr = ndST.getNetDistribution()
        let initialConductivity = netDistr[0][0] > 0 ? "P-type" : "N-type"  // ЗДЕСЬ определяется начальный тип проводимости. А раньше?
        
        // Type Sign: = 1.0 (p-Type) OR -1.0 (n-Type). Calculated for each g-value
        let sgn = TypeSigns.sharedInstance
        sgn.netDist = netDistr[0]
        let typeSigns = sgn.getSigns()
        
        // Compensation
        let cmp = Compensation.sharedInstance
        cmp.currentDopants = currentDopants
        cmp.dopDist = dopDistr
        //        cmp.typeSigns = typeSigns
        let compArray = cmp.getCompensation()
        
        // Resistivity
        let rdST = ResDistribution.sharedInstance
        rdST.currentDopants = currentDopants
        rdST.typeSigns = typeSigns
        let resDist = rdST.getResDistr()
        
        // Conductivity inversion
        let negST = NegRange.sharedInstance
        let negRange = negST.findNegRange(arr: netDistr[0])
        
        return (dopDistr,netDistr,compArray, resDist,negRange,initialConductivity)
    }
}


// All classes presented as Singletons

private class DopantsDistribution {
    static let sharedInstance = DopantsDistribution()
    
    var currentDopants:[String]?
    var initC:[Double]?
    var segCoeffs: [Double] {
        return currentDopants!.map{Constants.dopantsDict[$0]!.segCf}
    }
    
    func getDopantDistribution() -> [[Double]] {
        var x = [[Double]]()
        for i in 0..<currentDopants!.count {
            let k = segCoeffs[i]
            let C = initC![i]
            x.append((Constants.g).map{k*C*pow((1-$0),k-1.0)})
        }
        return x
    }
}

private class NetDistribution {
    static let sharedInstance = NetDistribution()
    
    var currentDopants:[String]?
    var dopDist:[[Double]]?
    
    func getNetDistribution() -> [[Double]] {
        var netDistr = [[Double]]()
        var realNet = [Double]()
        var netAbs = [Double]()
        var coeff = 1.0
        var conductivity:[String] {
            return currentDopants!.map{Constants.dopantsDict[$0]!.conductivity}
        }
        
        for j in 0..<(Constants.g).count {
            var currentNet = 0.0
            for i in 0..<currentDopants!.count {
                let cond = conductivity[i]
                coeff = cond == "P-type" ? 1.0 : -1.0
                currentNet += coeff*dopDist![i][j]
            }
            realNet.append(currentNet)
        }
        netAbs = realNet.map{abs($0)}
        netDistr = [realNet,netAbs]
        
        return netDistr
    }    
}

private class TypeSigns {
    static let sharedInstance = TypeSigns()
    var netDist:[Double]?
    func getSigns() -> [Double] {
        return netDist!.map{$0 > 0.0 ? 1.0 : -1.0}
    }
}

// Корректный учет типа проводимости (via sign of NetDistribution [0])
private class Compensation {
    static let sharedInstance = Compensation()
    
    var currentDopants:[String]?
    var dopDist:[[Double]]?
    
    func getCompensation() -> [Double] {
        var coeff = 1.0
        var Cl = 0.0
        var ClArray:[Double] = []
        
        for j in 0..<Constants.g.count {
            var currentNet = 0.0
            var sumP = 0.0
            var sumN = 0.0
            for i in 0..<currentDopants!.count {
                let type = Constants.dopantsDict[currentDopants![i]]!.conductivity
                coeff = type == "P-type" ? 1.0 : -1.0
                currentNet += dopDist![i][j]
                if coeff == 1.0  {sumP += dopDist![i][j]}
                if coeff == -1.0 {sumN += dopDist![i][j]}
            }
            Cl = (sumP+sumN)/(sumP-sumN)
            ClArray.append(Cl)
        }
        return ClArray.map{abs($0)}
    }
}

private class ResDistribution {
    static let sharedInstance = ResDistribution()
    
    var currentDopants:[String]?
    var typeSigns:[Double]?
    var realNet:[Double] {
        return NetDistribution.sharedInstance.getNetDistribution()[0]
    }
    // Это только для расчета по WFN-функциям (т.е. для  n- или p-типа, без привязки к конкретной примеси. Если применять формулы, учитывающие конкретную примесь, то ее надо ОПРЕДЕЛИТЬ и ПЕРЕДАТЬ!)
    func getResDistr() -> [Double ] {
        var conversionFunction: (Double) -> Double
        var resDistr = [Double]()
        var j = 0
        for i in 0..<(Constants.g).count {
            if typeSigns![j] == 1.0 {
                conversionFunction = converter("DD", initConductivity: "P-type")
            }
            else {
                conversionFunction = converter("DD", initConductivity: "N-type")
            }
            j += 1
            resDistr.append(conversionFunction(abs(realNet[i])))
        }
        return resDistr
    }
}

private class NegRange {
    static let sharedInstance = NegRange()
    
    func findNegRange(arr:[Double]) -> [Int] {
        var first:Int?
        var last:Int?
        var pred: (Double) -> Bool
        if arr[0] > 0 {
            pred = {(value: Double) -> Bool in return value < 0.0}
        }
        else {
            pred = {(value: Double) -> Bool in return value > 0.0}
        }
        first = arr.findFirstIndexDouble(predicate: pred)
        if first != nil {
            last = arr.count - 1 - arr.reversed().findFirstIndexDouble(predicate: pred)!
            return [first,last].map{$0!}
        }
        return []
    }
}
