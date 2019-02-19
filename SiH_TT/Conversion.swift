//
//  Conversion.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

final class CNV {
    
    // ASTM Conversion
    
    /**
     Calculate Boron Dopant Density from Resistivity value. ASTM
     */
    public static func RB2dd(_ inp:Double) -> Double
    {
        let kf = [1.33e16,1.082e17,54.56,1.105]
        return kf[0]/inp+kf[1]/(inp*(1+pow(inp*kf[2],kf[3])))
    }
    
    /**
     Calculate Phosphorus Dopant Density from Resistivity value. ASTM
     from Thurber xq*/
    public static func RP2dd(_ inp:Double) -> Double
    {
        var kf = [-3.1083,-3.2626,-1.2196,-0.13923,1.0265,0.38755,0.041833,6.242e18]
        var y=0.0
        y=log10(inp)     //      for R->DD
        
        let nom1=kf[0]+kf[1]*y+kf[2]*pow(y,2)
        let nom2=kf[3]*pow(y,3)
        let nominator=nom1+nom2
        let denumerator=1+kf[4]*y+kf[5]*pow(y,2)+kf[6]*pow(y,3)
        let quot=nominator/denumerator
        return kf[7]*pow(10,quot)/inp
    }
    
    /**
     Calculate Boron Resistivity from Dopant Density value. ASTM
     */
    public static func DDB2R(_ inp:Double)->Double
    {
        var kf = [1.305e16,1.133e17,2.58e-19,-0.737]                                    // B
        return kf[0]/inp+kf[1]/(inp*(1+pow(inp*kf[2],kf[3])))
    }
    
    /**
     Calculate Phosphorus Resistivity from Dopant Density value. ASTM
     */
    public static func DDP2R(_ inp:Double)->Double
    {
        var kf=[-3.0769,2.2108,-0.62272,0.057501,-0.68157,0.19833,-0.018376,6.242e18]   // P
        let y = (kf[0] == -3.1083) ? log10(inp) : log10(inp)-16
        // Для R->DD: y=log10(inp); для DD->R: y=log10(inp)-16
        
        let numerator = kf[0]+kf[1]*y+kf[2]*pow(y,2) + kf[3]*pow(y,3)
        let denominator=1+kf[4]*y+kf[5]*pow(y,2)+kf[6]*pow(y,3)
        let quot=numerator/denominator
        
        let x=kf[7]*pow(10,quot)/inp
        return x
    }
    
    // Conversion http://www.wafernet.com/calculator.asp
    // The same at: http://www.solecon.com/sra/rho2ccal.htm
    
    /**
     Calculate P-Type Dopant Density from Resistivity value.
     */
    public static func pR2C(_ rho:Double) -> Double {
        let r = log(rho)
        var pmu = 482.8/(1 + 0.1322/pow(rho,0.811))
        if rho <= 0.1 {
            pmu += 52.4*exp(-rho/0.00409)
        }
        return exp(43.28 - r - log(pmu))
    }
    
    /**
     Calculate N-Type Dopant Density from Resistivity value.
     */
    public static func nR2C(_ rho:Double) -> Double {
        let r = log(rho)
        let x = r*0.4343
        var nmu = 0.0
        if r > -6.9 {
            let numerator   = 3.1122 + x * (3.3347 + x * (1.261  + x * 0.15701))
            let denominator = 1      + x * (1.0463 + x * (0.39941 + x * 0.049746))
            nmu = pow(10,(numerator/denominator))
        }
        else {
            nmu = 163 + 26 * x
        }
        
        return exp(43.28 - r - log(abs(nmu)))
    }
    
    /**
     Calculate P-Type Resistivity from Dopant Density value.
     */
    public static func pC2R(_ conc:Double) -> Double {
        var lowRho = 1.1e-4
        var highRho = 6.5e6
        var guessing = true
        var guessRho = 0.0
        while guessing {
            guessRho = (lowRho + highRho)/2
            let guessPConc = pR2C(guessRho)
            if guessPConc == conc || guessRho == lowRho || guessRho == highRho {
                guessing = false
            }
            else if guessPConc < conc {highRho = guessRho}
            else {lowRho = guessRho}
        }
        return guessRho
    }
    
    /**
     Calculate N-Type Resistivity from Dopant Density value.
     */
    public static func nC2R(_ conc:Double) -> Double {
        var lowRho = 1.0e-4
        var highRho = 2.2e6
        var guessing = true
        var guessRho = 0.0
        while guessing {
            guessRho = (lowRho + highRho)/2
            let guessPConc = nR2C(guessRho)
            if guessPConc == conc || guessRho == lowRho || guessRho == highRho {
                guessing = false
            }
            else if guessPConc < conc {highRho = guessRho}
            else {lowRho = guessRho}
        }
        return guessRho
    }
    
    // Resistivity & Mobility Calculator: C->R for Boron, Phosphorus and Arsenic
    // http://www.cleanroom.byu.edu/ResistivityCal.phtml
    
    public static func rmcCB2R(_ conc:Double) -> Double {
        let umin = 44.9
        let umax = 470.5
        let nrB = 2.23e17
        let alpha = 0.719
        let q = 1.60218e-19
        
        let mob = umin + (umax - umin)/(1 + pow(conc/nrB,alpha))
        
        return 1/(q*conc*mob)
    }
    public static func rmcCP2R(_ conc:Double) -> Double {
        let umin = 68.5
        let umax = 1414.0
        let nrB = 9.2e16
        let alpha = 0.711
        let q = 1.60218e-19
        
        let mob = umin + (umax - umin)/(1 + pow(conc/nrB,alpha))
        
        return 1/(q*conc*mob)
    }
    public static func rmcCAs2R(_ conc:Double) -> Double {
        let umin = 52.2
        let umax = 1417.0
        let nrB = 9.68e16
        let alpha = 0.68
        let q = 1.60218e-19
        
        let mob = umin + (umax - umin)/(1 + pow(conc/nrB,alpha))
        
        return 1/(q*conc*mob)
    }
  
}

// Функция, возвращающая ФУНКЦИЮ !!!
// Эта функция пока "живет" отдельно и конвертирует по WFN-формулам. Для варианта C -> R (т.е. DD) желательно сделать расчет по RMC (в зависимости от основной примеси)
// Сюда желательно передавать ОСНОВНУЮ примесь
func converter(_ convertFrom:String, initConductivity:String) -> ((Double) -> Double) {
    var x = CNV.pR2C
    switch convertFrom {
    case "R":
        x = (initConductivity=="P-type") ? CNV.pR2C : CNV.nR2C
    case "DD":
        x = (initConductivity=="P-type") ? CNV.pC2R : CNV.nC2R
    default: ()
    }
    return x
}


// Функция, возвращающая ФУНКЦИЮ !!!
/**
 Defines which function to use for conversion
 ## Arguments ##
 1. convertFrom - "R" or "C" letter.
 * "R" - conversion **from Resistivity to Dopant Density**
 * "C" - conversion **from Dopant Density to Resistivity**
 2. dopant - Dopant shortName
 */
// ВАЖНО!!! В данном случае функция для конверсии определяется ПО НАЗВАНИЮ ПЕРВОЙ ПРИМЕСИ! Вообще это не так: для достижения требуемого профиля удельного сопротивления начальные концентрации могут быть и для P-, и для N-типа!!!
// Пока конвертация через WFN-функции
//func convFunc(_ convertFrom:String, dopant:String) -> ((Double) -> Double) {
//    var x = CNV.RB2dd
//    switch convertFrom {
//    case "R":
//        x = (dopant=="B") ? CNV.pR2C : CNV.nR2C
//    default:
//        x = (dopant=="B") ? CNV.pC2R : CNV.nC2R
//    }
//    return x
//}
