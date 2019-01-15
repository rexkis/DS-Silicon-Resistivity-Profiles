//
//  Extensions.swift
//  SiHelper
//
//  Created by Igor Kutovoy on 15.12.16.
//  Copyright © 2016 Igor Kutovoy. All rights reserved.
//

import Cocoa

// Проверка введенного в UITextField значения: поле не должно быть пустым и может быть конвертировано в Double
extension NSTextField {
    var checkPassed:Bool {
        guard !self.stringValue.isEmpty , let toDouble = Double(self.stringValue) , toDouble > 0 else {
            return false }
        return true
    }
}

// Разложение числа на степень и значение перед ней (>=1)
extension Double {
    var decomp:(value:Double,digit:Int) {
//        var value = Double(self)
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
}
extension Double {
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

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
//    func substring(from: Int) -> String {
//        let fromIndex = index(from: from)
//        return substring(from: fromIndex)
//    }
    
//    func substring(to: Int) -> String {
//        let toIndex = index(from: to)
//        return substring(to: toIndex)
//    }
    
//    func substring(with r: Range<Int>) -> String {
//        let startIndex = index(from: r.lowerBound)
//        let endIndex = index(from: r.upperBound)
//        return substring(with: startIndex..<endIndex)
//    }
    
//    func firstIndexOf(character: Character) -> Int {
////        return self.distance(from:self.startIndex, to:self.characters.index(of:character)!)
//        return self.distance(from:self.startIndex, to:self.index(of:character)!)
//    }
    
    func indexDistance(of character: Character) -> Int? {
//        guard let index = characters.index(of: character) else { return nil }
        guard let index = self.index(of: character) else { return nil }             // SWIFT 4 Toolchain
        return distance(from: startIndex, to: index)
    }
}

extension String {
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
public extension NSBezierPath {
    
    public var CGPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: NSPoint(x: points[0].x, y: points[0].y))
            case .lineToBezierPathElement: path.addLine(to: NSPoint(x: points[0].x, y: points[0].y))
            case .curveToBezierPathElement: path.addCurve(to: NSPoint(x: points[0].x, y: points[0].y), control1: NSPoint(x: points[1].x, y: points[1].y), control2: NSPoint(x: points[2].x, y: points[2].y))
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
    }
    /*
 
     public extension NSBezierPath {
     
        public var CGPath: CGPath {
            let path = CGMutablePath()
            var points = [CGPoint](repeating: .zero, count: 3)
            for i in 0 ..< self.elementCount {
                let type = self.element(at: i, associatedPoints: &points)
                switch type {
                case .moveToBezierPathElement: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
                case .lineToBezierPathElement: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
                case .curveToBezierPathElement: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                    control1: CGPoint(x: points[0].x, y: points[0].y),
                    control2: CGPoint(x: points[1].x, y: points[1].y) )
                case .closePathBezierPathElement: path.closeSubpath()
                }
            }
            return path
        }
     }

     */
    
}

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
    
    /**
     * Round float to a specific step value
     */
    public func roundTo(_ to: CGFloat) -> CGFloat {
        let remainder = self.truncatingRemainder(dividingBy: to)
        if remainder >= to / 2 {
            return self + to - remainder
        } else {
            return self - remainder
        }
    }
}
