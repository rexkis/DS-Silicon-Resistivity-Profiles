//
//  Titles.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 16/03/2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

import Cocoa

class Titles {
    // Initializing variables
    var dopants = [String]()
    var calcType: CalcType = .customR
    var concs: [Double] = []
//    var resistivityProfile = [Double]()
    
    
    init(dopants: [String]) {
        self.dopants = dopants
    }
    init(calcType: CalcType) {
        self.calcType = calcType
    }
    init(dopants: [String],calcType: CalcType) {
        self.dopants = dopants
        self.calcType = calcType
    }
    init(calcType: CalcType, dopants: [String], concs:[Double]) {
        self.calcType = calcType
        self.dopants = dopants
        self.concs = concs
    }
    
    // Vars via Constants
    var gExtraLabels:[String] {
        return dopants.count == 2 ? ["g = 0.05", "g = 0.85"] : ["g = 0.05", "g = 0.50", "g = 0.85"]
    }
    var dopantsDescriptionArray:[String] {
        var arr = [String]()
        for i in 0..<dopants.count {
            arr.append(Constants.dopantsDict[dopants[i]]!.description)
        }
        return arr
    }
    
    // Helper String Functions
    // a) "at/cm3",
    var atcm3:NSMutableAttributedString {
        let attString = "at/cm3".attr()
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:5,length:1))
        return attString
    }
    // b) data with superscript
    func concWithSuper(value:NumDecomposed) -> NSMutableAttributedString {
        let str = [(value.value).styled,"∙10",String(value.digit)].joined()
        let attString = str.attr()
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:7,length:2))
        return attString
    }

    var inputLabels = [String]()
    var inputTitle:NSMutableAttributedString = NSMutableAttributedString(string: "")
    var resultLabels = [String]()
    var resultTitle:NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    // Title & Labels for InputView ======================================
    func setInputLabels() -> [String] {
        switch calcType {
        case .customDD:
            inputLabels = dopantsDescriptionArray
        case .customR:
            inputLabels = gExtraLabels
        }
        return inputLabels
    }
    func setInputTitle() -> NSMutableAttributedString {
        switch calcType {
        case .customDD:
            inputTitle = inputTitleLabelsText[1]
        case .customR:
            inputTitle = inputTitleLabelsText[0]
        }
        return inputTitle
    }
    var inputTitleLabelsText: [NSMutableAttributedString] {
        let first = "Set Target Resistivities, Ohm∙cm, at solidified fraction".attr()
        let second = "Set source Dopant Densities in Feedstock, ".attr()
        second.append(atcm3)
        let out = [first,second]
        for str in out {
            str.setAlignment(.center, range: NSRange(location: 0, length: str.length))
        }
        return out
    }
    
    // Title & Labels for ResultView ======================================
    func setResultLabels() -> [String] {
        switch calcType {
        case .customDD:
            resultLabels = gExtraLabels
        case .customR:
            resultLabels = dopantsDescriptionArray
        }
        return resultLabels
    }
    func setResultTitle() -> NSMutableAttributedString {
        switch calcType {
        case .customDD:
            resultTitle = resultTitleLabelsText[1]
        case .customR:
            resultTitle = resultTitleLabelsText[0]
        }
        return resultTitle
    }
    var resultTitleLabelsText: [NSMutableAttributedString] {
        let first = "Source Dopant Densities in Feedstock, ".attr()
        let second = "Resistivities, Ohm∙cm, at solidified fraction checkpoints".attr()
        first.append(atcm3)
        let out = [first,second]
        for str in out {
            str.setAlignment(.center, range: NSRange(location: 0, length: str.length))
        }
        return out
    }
    
    // Title & Labels for ChartView ======================================
//    func setCustomLabel() -> NSMutableAttributedString {
//        var customLabel = NSMutableAttributedString(string: "")
//        switch calcType {
//        case .customR:
//            customLabel = chartResString(calcType: calcType, checkpoints: checkpoints,resProfile: resistivityProfile)
//        default:
//            <#code#>
//        }
//        
//        return NSMutableAttributedString(string: "")
//    }
    func chartDDString(calcType:CalcType, dopants:[String], concs:[Double]) -> NSMutableAttributedString {
        var concStr:NSMutableAttributedString = NSMutableAttributedString(string: "")
        switch calcType {
        case .customR:
            concStr = "Calculated Feedstock Dopant Densities: ".attr()
        default:
            concStr = "Custom Dopant Densities: ".attr()
        }
        
        let descr = dopants.map{Constants.dopantsDict[$0]!.description}
        for i in 0..<concs.count {
            concStr.append((descr[i] + " ").attr())
            concStr.append(concWithSuper(value: concs[i].decomp))
            if i != concs.count - 1 {
                concStr.append(NSMutableAttributedString(string: ", "))
            }
            else {
                concStr.append(NSMutableAttributedString(string: " "))
            }
        }
        concStr.append(atcm3)
        return concStr
    }
    
    func chartResString(calcType:CalcType,checkpoints:String,resProfile:[Double]) -> NSMutableAttributedString {
        var resStr = resProfile.map{String(format:"%4.2f",$0)}
        var str = ""
        switch calcType {
        case .customR:
            str = "Custom Resistivities at g = \(checkpoints) are equal ["
        case .customDD:
            str = "Calculated Resistivities at g = \(checkpoints) are equal ["
        }
        let cnt = resProfile.count
        for i in 0..<cnt {
            str.append(resStr[i])
            if i != cnt - 1 {
                str.append(", ")
            }
            else {
                str.append("] Ohm∙cm ")
            }
        }
        return str.attr()
    }
    
    
    
    
}
