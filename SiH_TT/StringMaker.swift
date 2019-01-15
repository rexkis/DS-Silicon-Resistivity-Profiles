//
//  StringMaker.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 16.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

class StringMaker: NSObject {
    
    var atcm3:NSMutableAttributedString {
        return substringSuper(string: "at/cm3", char: "3", offset: 0, length: 1)
    }
    
    private func substringSuper(string:String,char:Character, offset: Int, length: Int) -> NSMutableAttributedString {
        let fontName = "Helvetica"
        let fontSize:CGFloat = 12
        let superFontSize:CGFloat = fontSize*0.7
        
        let dist = string.indexDistance(of: char)
        let range = NSRange(location: dist! + offset, length: length)
        let attr = NSMutableAttributedString(string: string)
        attr.superscriptRange(range)
        attr.addAttribute(NSAttributedStringKey.font, value: NSFont(name: fontName, size: superFontSize)!, range: range)
        return attr
    }
    
    // Converts previously prepared strings of definite (and ONLY this!) format (ex: "1.25∙1016") and make degree (16) superscripted
    // P.S. Degree may consists of [zero to inf numbers]. "Control point" - multiplication sign "∙"
    func makeDegreeSuper(string:String) -> NSMutableAttributedString {
        let fontName = "Helvetica"
        let fontSize:CGFloat = 12
        let superFontSize:CGFloat = fontSize*0.7
        let degreeLength = string.count - 7
        let range = NSRange(location: 7, length: degreeLength)
        let attr = NSMutableAttributedString(string: string)
        attr.superscriptRange(range)
        attr.addAttribute(NSAttributedStringKey.font, value: NSFont(name: fontName, size: superFontSize)!, range: range)
        return attr
    }
    
    // Titles for Input and Result views
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
    
    var resultTitleLabelsText: [NSMutableAttributedString] {
        let first = "Source Dopant Densities in Feedstock, ".attr()
        let second = "Resistivities, Ohm∙cm, at solidified fraction checkpoints".attr()
        
        second.append(atcm3)

        let out = [first,second]
        for str in out {
            str.setAlignment(.center, range: NSRange(location: 0, length: str.length))
        }
        return out
    }

    // Custom & Calculated Titles for Chart view
    
    // New functions
    func concWithSuper(value:NumDecomposed) -> NSMutableAttributedString {
        
        let attrStr = NSMutableAttributedString(string: String(format:"%4.2f",value.value) + "∙10")
        let gegreeString = String(value.digit)
        let range = NSRange(location: 0, length: gegreeString.count)
        let degree = gegreeString.attr()
        degree.superscriptRange(range)
        degree.addAttribute(NSAttributedStringKey.font, value: NSFont(name: "Helvetica", size: 8.4)!, range: range)
        attrStr.append(degree)
        
        return attrStr
    }
    func chartDDString(calcType:CalcType, dopants:[String], concs:[Double]) -> NSMutableAttributedString {
        
        var concStr = "".attr()
        let descr = dopants.map{Constants.dopantsDict[$0]!.description}
        concStr = calcType == .customR ? "CALCULATED Feedstock Dopant Densities: ".attr()
            : "CUSTOM Dopant Densities: ".attr()
        
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
    
//    // Old function
//    func chartDDString(calcType:CalcType, dopants:[String], concs:[Double]) -> NSAttributedString  {
//        var concStr = NSMutableAttributedString(string: "")
//        let dopDescriptions = dopants.map{Constants.dopantsDict[$0]!.description}
//        let strings = concs.map{String(format:"%4.2f",$0.decomp.value) + "∙10" + String($0.decomp.digit)}
////        let strings = _strings.map{makeDegreeSuper(string: $0)}
//        var fullStrings = [String]()
//        for i in 0..<dopants.count {
//            fullStrings.append(dopDescriptions[i] + " " + strings[i])
//        }
//        
//        var f = fullStrings.map{substringSuper(string: $0, char: "∙", offset: 3, length: 2)}
////        var f = fullStrings.map{makeDegreeSuper(string: $0)}
//        
//        switch calcType {
//        case .customR:
//            concStr = NSMutableAttributedString(string: "CALCULATED Feedstock Dopant Densities: ")
//        case .customDD:
//            concStr = NSMutableAttributedString(string: "CUSTOM Feedstock Dopant Densities: ")
//        }
//        
//        for i in 0..<f.count {
//            concStr.append(f[i])
//            if i != f.count - 1 {
//                concStr.append(NSMutableAttributedString(string: ", "))
//            }
//            else {
//                concStr.append(NSMutableAttributedString(string: " "))
//            }
//        }
//        concStr.append(atcm3)
//        
//        return concStr
//    }
    
    func chartResString(calcType:CalcType,checkpoints:String,resProfile:[Double]) -> NSMutableAttributedString {
        var resStr = resProfile.map{String(format:"%4.2f",$0)}
        var str = ""
        switch calcType {
        case .customR:
            str = "CUSTOM Resistivities at g = \(checkpoints) are equal ["
        case .customDD:
            str = "CALCULATED Resistivities at g = \(checkpoints) are equal ["
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
        
        return NSMutableAttributedString(string: str)
    }

}
