//
//  Extensions.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa


extension NSTextField {
    // Check UITextField entered value: must be NO EMPTY, may be converted to Double
    var checkPassed:Bool {
        guard !self.stringValue.isEmpty , let toDouble = Double(self.stringValue) , toDouble > 0 else {
            return false }
        return true
    }
}

extension Double {
    // Decomposition of a number into a power and the value in front of it (value>=1)
    var decomp:(value:Double,digit:Int) {
        var value = self
        var digit:Int
        if value < 1 {
            digit = Int(ceil(log10(self)) - 1.0)
            while value < 1 {
                value *= 10
            }
        }
        else {
            digit = Int((log10(self)))
            value = (self)/pow(10,Double(digit))
        }
        
        return (value,digit)
    }
    
    // Formatting Number type
    struct Number {
        static var formatter = NumberFormatter()
    }
    var expStyle:String {
        Number.formatter.locale = Locale(identifier: "US")
        Number.formatter.numberStyle = .scientific
        //        Number.formatter.positiveFormat = "0.##E+0"
        Number.formatter.positiveFormat = "0.##E0"
        Number.formatter.exponentSymbol = "e"
        return Number.formatter.string(from: self as NSNumber) ?? description
    }
    var fixStyle:String {
        return String(format: "%4.2f", self)
    }
    var styled:String {
        if self >= 1000 || self <= 0.01 {
            return self.expStyle
        }
        else {
            return self.fixStyle
        }
    }
}

// Расширение для массива Double: в массиве ищется первое значение, удовлетворяющее предикату. В моем случае сам предикат определяется отдельно в функции findNegRange(arr:[Double]) для N- и P-типов проводимости. Если первое значение массива Net больше нуля (т.е. P-тип), ищется первое значение меньше нуля. Для N-типа - значание больше нуля.
extension Sequence where Self.Iterator.Element == Double {
    func findFirstIndexDouble(predicate: (Double) -> Bool) -> Int? {
        for (idx,value) in self.enumerated() where predicate(value) {
            return idx
        }
        return nil
    }
}

// Расширение для String, которое позволяет обращаться к нему не по String.Index, а по Int
// Используется для AttributedString
extension String {
    
    func attr() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }

    func indexDistance(of character: Character) -> Int? {
        guard let index = self.index(of: character) else { return nil }             // SWIFT 4 Toolchain
        return distance(from: startIndex, to: index)
    }
    
    // Control number of dots and e(E)-letters to control entered value in NSTextfield
    var dots:Int {
        return self.components(separatedBy: ".").count - 1
    }
    var exps:Int {
        let lowE = self.components(separatedBy: "e").count - 1
        let highE = self.components(separatedBy: "E").count - 1
        return lowE + highE
    }
}

// https://gist.github.com/mayoff/d6d9738860ef2d0ac4055f0d12c21533
//public extension NSBezierPath {
//    public var CGPath: CGPath {
//        let path = CGMutablePath()
//        var points = [CGPoint](repeating: .zero, count: 3)
//        for i in 0 ..< self.elementCount {
//            let type = self.element(at: i, associatedPoints: &points)
//            switch type {
//            case .moveToBezierPathElement: path.move(to: NSPoint(x: points[0].x, y: points[0].y))
//            case .lineToBezierPathElement: path.addLine(to: NSPoint(x: points[0].x, y: points[0].y))
//            case .curveToBezierPathElement: path.addCurve(to: NSPoint(x: points[0].x, y: points[0].y), control1: NSPoint(x: points[1].x, y: points[1].y), control2: NSPoint(x: points[2].x, y: points[2].y))
//            case .closePathBezierPathElement: path.closeSubpath()
//            }
//        }
//        return path
//    }
//}

// NSTextView автоматически вызывает touchBar с "текстовыми" функциями. Для того, чтобы отменить это действие по умолчанию, используем это расширение!
extension NSTextView {
    
    @available(OSX 10.12.2, *)
    override open func makeTouchBar() -> NSTouchBar? {
        
        let touchBar = super.makeTouchBar()
        touchBar?.delegate = self
        return touchBar
    }
}

public extension CGFloat {
    // Round float to a specific step value
    public func roundTo(_ to: CGFloat) -> CGFloat {
        let remainder = self.truncatingRemainder(dividingBy: to)
        if remainder >= to / 2 {
            return self + to - remainder
        } else {
            return self - remainder
        }
    }
}
