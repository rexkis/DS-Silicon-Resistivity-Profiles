//
//  StringMaker.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 16.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

class StringMaker: NSObject {
    
    // Superscripts for
    // a) "at/cm3",
    var atcm3:NSMutableAttributedString {
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "at/cm3", attributes: [.font:Constants.font!])
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:5,length:1))
        return attString
    }
    // b) concentrations in GraphView
    func concWithSuper(value:NumDecomposed) -> NSMutableAttributedString {
        let str = String(format:"%4.2f", value.value) + "∙10" + String(value.digit)
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: str, attributes: [.font:Constants.font!])
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:7,length:2))
        return attString
    }

    // Titles Input view
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
    // Titles for Result view
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
    func chartDDString(calcType:CalcType, dopants:[String], concs:[Double]) -> NSMutableAttributedString {
        
        var concStr = "".attr()
        let descr = dopants.map{Constants.dopantsDict[$0]!.description}
        concStr = calcType == .customR ? "Calculated Feedstock Dopant Densities: ".attr()
            : "Custom Dopant Densities: ".attr()
        
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
        return NSMutableAttributedString(string: str, attributes: [.font:Constants.font!])
    }

}
