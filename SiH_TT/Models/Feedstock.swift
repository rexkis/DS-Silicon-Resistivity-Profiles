//
//  Feedstock.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa
import Accelerate

class Feedstock: NSObject {
    
    // Initializing
    var currentDopants:[String]
    var inputFields:[Double]
    
    // Computed properties
    private var dopantsCount: Int = 0
    private var conductivity:String = ""
    private var multipliers = [Double]()
    private var leftMatrix = [Double]()
    private var rightMatrix = [Double]()
    
    // Output property
    public var initConcs:[Double] = []
    
    public init(currentDopants:[String], inputFields:[Double]) {
        self.currentDopants = currentDopants
        self.inputFields = inputFields
        
        dopantsCount = currentDopants.count
        conductivity = currentDopants.first == "B" || currentDopants.first == "Ga" ? "P-type" : "N-type"
        super.init()
        multipliers = getMultipliers()
        leftMatrix = getLeftMatrix()
        rightMatrix = getRightMatrix()

        initConcs = getInitConcs()
    }
    
    private func getMultipliers() -> [Double] {
        var mult = Array<Double>(repeating: 0.0, count: dopantsCount)
        var m = 0.0
        var condArray = currentDopants.map{Constants.dopantsDict[$0]!.conductivity}
        for i in 0..<dopantsCount {
            m = condArray[i] == conductivity ? 1.0 : -1.0
            mult[i] = m
        }
        return mult
    }
    
    private func getLeftMatrix() -> [Double] {
        var leftMatrix = [Double]()
        var mult = getMultipliers()
        let checkPoints = dopantsCount == 2 ? [0.05,0.85] : [0.05,0.50,0.85]
        // Расчет левой матрицы
        for i in 0..<dopantsCount {      // Loop for columns
            for j in 0..<dopantsCount {  // Loop for rows
                let k = Constants.dopantsDict[currentDopants[j]]!.segCf
                var value = k*pow(1 - checkPoints[i], k - 1)
                value *= mult[j]
                leftMatrix.append(value)
            }
        }
        return leftMatrix
    }
    
    private func getRightMatrix() -> [Double] {
        let convFunc:(Double) -> Double = conductivity == "P-type" ? CNV.pR2C : CNV.nR2C
        let rightMatrix = inputFields.map{convFunc($0)}
        return rightMatrix
    }
    
    private func getInitConcs() -> [Double] {
        let N = UInt(dopantsCount)
        
        let mat = la_matrix_from_double_buffer(leftMatrix, N, N, N, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let vec = la_matrix_from_double_buffer(rightMatrix, N, 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        let vecCj = la_solve(mat, vec)
        var cj: [Double] = Array(repeating: 0.0, count: dopantsCount)
        let status = la_matrix_to_double_buffer(&cj, 1, vecCj)
        if status == la_status_t(LA_SUCCESS) {
            return cj
        } else {
            print("Failure: \(status)")
            return []
        }
    }
}

