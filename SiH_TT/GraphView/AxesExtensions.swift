//
//  AxesExtensions.swift
//  SomeNewAxis
//
//  Created by Igor Kutovoy on 05.06.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

extension YAxis {
    func getYCoord(_ value:Double) -> CGFloat {
        let a = log(axisMinMax[1])
        let b = log(axisMinMax[0])
        let mult = Double(yAxisLength*GConstants.tickedAxisSpace)/(a - b)
        let yCoord = Double(origin.y) + (log(value) - b)*mult
        return CGFloat(yCoord)
    }
    func getMajorDigits() -> [Int] {
        var majorDigits = [minY.digit,maxY.digit]
        let n = maxY.digit - minY.digit
        if n > 1 {
            for i in 1..<n {
                majorDigits.insert(majorDigits[0] + i, at: i)
            }
        }
        if n == 0 {majorDigits.removeLast()}
        if minY.value > 1 {majorDigits.remove(at: 0)}
        return majorDigits
    }
    func getMajorValues() -> [Double] {
        var majorValues = [Double]()
        if major.digits != [] {
            majorValues = major.digits.map{pow(10.0,Double($0))}
        }
        return majorValues
    }
    func getMinorDigits() -> [Int] {
        var minorDigits = [Int]()
        if major.digits == [] {
            minorDigits.append(maxY.digit)
        }
        else {
            minorDigits = major.digits
            if minY.digit < major.digits[0]  && Int(minY.value) != 9 {
                minorDigits.insert(minY.digit, at: 0)
            }
        }
        return minorDigits
    }
    func getMinorValues() -> [Double] {
        let outerLoops = minor.digits.count == 1 ? 0 : minor.digits.count - 1
        var minorValues = [Double]()
        var startInnerLoopIndex = 0
        var endInnerLoopIndex = 0
        
//        if minor.digits.count == 1 {
//            startInnerLoopIndex = Int(minY.value) != 1 ? Int(ceil(minY.value)) : 2
//            endInnerLoopIndex = Int(maxY.value) != 1 ? Int(maxY.value) : 9
//        }
        
        for i in 0...outerLoops {

            if i == 0 { // Все данные в пределах одного степенного диапазона
                startInnerLoopIndex = (Int(minY.value) != 1) && (Int(minY.value) != 9) ? Int(ceil(minY.value)) : 2
                endInnerLoopIndex = outerLoops != 0 ? 9 : Int(maxY.value)
                for j in startInnerLoopIndex...endInnerLoopIndex {
                    minorValues.append(Double(j)*pow(10.0,Double(minor.digits[i])))
                }
            }
            if i > 0 && i < outerLoops {    // Промежуточные степенные диапазоны
                startInnerLoopIndex = 2
                endInnerLoopIndex = 9
                for j in startInnerLoopIndex...endInnerLoopIndex {
                    minorValues.append(Double(j)*pow(10.0,Double(minor.digits[i])))
                }
            }
            if i == outerLoops && outerLoops != 0 { // Последний степенной диапазон
                startInnerLoopIndex = Int(maxY.value) > 1 ? 2 : 0
                if startInnerLoopIndex != 0 {
                    endInnerLoopIndex = Int(maxY.value)
                    for j in startInnerLoopIndex...endInnerLoopIndex {
                        minorValues.append(Double(j)*pow(10.0,Double(minor.digits[outerLoops])))
                    }
                }
            }
        }
        return minorValues
    }

}
