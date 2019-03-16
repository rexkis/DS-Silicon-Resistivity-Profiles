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
        let attString = "at/cm3".attr()
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:5,length:1))
        return attString
    }
    // b) concentrations in GraphView
    func concWithSuper(value:NumDecomposed) -> NSMutableAttributedString {
        let str = [String(format:"%4.2f", value.value),"∙10",String(value.digit)].joined()
        let attString = str.attr()
        attString.setAttributes([.font:Constants.fontSuper!,.baselineOffset:4], range: NSRange(location:7,length:2))
        return attString
    }

    // Custom & Calculated Titles for Chart view
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
