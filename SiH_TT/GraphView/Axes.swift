//
//  Axes.swift
//  SomeNewAxis
//
//  Created by Igor Kutovoy on 02.06.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

typealias YTicksData = (digits:[Int],values:[Double],labels:[String])
typealias NumDecomposed = (value:Double,digit:Int)
//typealias YAxisData = (major:YTicksData,minor:YTicksData,yAxisMinMax:[Double])

// Инициализация этого класса не требуется: она будет при инициализации класса Axis
public class ChartBounds {
    var chartBounds: CGRect
    let origin = GConstants.chartOrigin
    
    init(chartBounds: CGRect) {
        self.chartBounds = chartBounds
    }
}

// Базовый класс для осей X, Y
public class Axis:ChartBounds {
    var gridEnabled:Bool
    var data:Any
    
    init(chartBounds:CGRect,gridEnabled:Bool,data:Any) {
        self.gridEnabled = gridEnabled
        self.data = data
        super.init(chartBounds:chartBounds)
    }
    
//    let context = NSGraphicsContext.current?.cgContext    // ????????????????
    let path = NSBezierPath()
    let gridPath = NSBezierPath()
    
    var xAxisLength:CGFloat {
        return chartBounds.width - origin.x - GConstants.chartInsets.right
    }
    var yAxisLength:CGFloat {
        return chartBounds.height - origin.y - GConstants.chartInsets.top
    }
    
    var major:YTicksData = (digits:[Int](),values:[Double](),labels:[String]())
    var majCoords = [CGFloat]()
    var minor:YTicksData = (digits:[Int](),values:[Double](),labels:[String]())
    var minCoords = [CGFloat]()
    var delta:CGFloat = 0.0
    
    func makeLine(path:NSBezierPath, fromPoint:NSPoint, toPoint:NSPoint) {
        path.lineWidth = 0.4
        path.move(to: fromPoint)
        path.line(to: toPoint)
    }
    
    func drawLine() {}
    func drawTicks() {}
    func drawLabels() {}
    func getAxis() {}
}

// Get DATA and AXIS min/max (all for YAxis). Напрямую инициализировать не надо: будет инициализирован вместе с YAxis
class AxisLimits {
    var data: Any
    
    init(data: Any) {
        self.data = data
    }
    
    var minmax:[Double] {
        return getMinMax(data)
    }
    var axisMinMax:[Double] {
        return getYAxisMinMax()
    }
    var a:CGFloat {
        return CGFloat(log(axisMinMax[1]))
    }
    var b:CGFloat {
        return CGFloat(log(axisMinMax[0]))
    }
    private func getMinMax(_ arr: Any) -> [Double] {
        switch arr {
        case let arr as [[Double]]:
            return [(arr.flatMap{$0}).min()!, (arr.flatMap{$0}).max()!]
        case let arr as [Double]:
            return [arr.min()!, arr.max()!]
        case let arr as [Int]:
            return [Double(arr.min()!), Double(arr.max()!)]
        default:
            Swift.print("Input argument is not of type [Double]/[[Double]]/[Int]")
        }
        return []
    }
    private func getYAxisMinMax() -> [Double] {
        let minValRounded = roundDown(minmax[0].decomp.value, toNearest: 0.01)
        let minDigit = minmax[0].decomp.digit
        let maxValRounded = roundUp(minmax[1].decomp.value, toNearest: 0.01)
        let maxDigit = minmax[1].decomp.digit
        
        let yAxisMin = minValRounded > 1 ? minValRounded*pow(10,Double(minDigit)) : pow(10,Double(minDigit))
        let yAxisMax = maxValRounded >= 8 ? pow(10,Double(maxDigit + 1)) : maxValRounded*pow(10,Double(maxDigit))
        return [yAxisMin,yAxisMax]
    }
    private func roundUp(_ number: Double, toNearest: Double) -> Double {
        return ceil(number / toNearest) * toNearest
    }
    private func roundDown(_ number: Double, toNearest: Double) -> Double {
        return floor(number / toNearest) * toNearest
    }
    
}

// X-Axis Class
class XAxis:Axis {
    
    override init(chartBounds: CGRect, gridEnabled: Bool, data:Any) {
        super.init(chartBounds: chartBounds, gridEnabled: gridEnabled, data:data)
        self.major.values = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
        self.major.labels = major.values.map{String($0)}
    }
    
    var mainXTickStep: CGFloat {
        return xAxisLength*GConstants.tickedAxisSpace/CGFloat(major.values.count)
    }
    override func drawLine() {
        makeLine(path: path,
                 fromPoint: origin,
                 toPoint: NSPoint(x: chartBounds.width - GConstants.chartInsets.right, y: origin.y))
        path.stroke()
    }
    override func drawTicks() {
        var delta:CGFloat = 0
        for i in 1..<2*major.values.count + 1 {
            delta = i%2 == 0 ? 5.0 : 3.5
            
            makeLine(path: path,
                     fromPoint: NSPoint(x:origin.x + CGFloat(i)*mainXTickStep/2, y: origin.y - delta),
                     toPoint: NSPoint(x:origin.x + CGFloat(i)*mainXTickStep/2, y: origin.y + delta))
            
            if i%2 == 0, gridEnabled == true {
                makeLine(path: gridPath,
                         fromPoint: NSPoint(x:origin.x + CGFloat(i)*mainXTickStep/2, y: origin.y + delta),
                         toPoint: NSPoint(x:origin.x + CGFloat(i)*mainXTickStep/2, y: origin.y + yAxisLength*GConstants.tickedAxisSpace))
            }
        }
        path.stroke()
        
        if gridEnabled == true {
            gridPath.lineWidth = 0.1
            gridPath.stroke()
        }
        
    }
    override func drawLabels() {
        let markSize = GConstants.xMarkSize
        let xLabelStrings = major.values.map{String($0)}
        for i in 1..<major.values.count + 1 {
            let mark = xLabelStrings[i-1]
            let markRect = NSRect(x: origin.x + CGFloat(i)*mainXTickStep - markSize.width/2,
                                  y: origin.y - 20,
                                  width: markSize.width, height: markSize.height)
            mark.draw(in: markRect, withAttributes: GConstants.markAttributes)
        }
    }
    override func getAxis() {
        drawLine()
        drawTicks()
        drawLabels()
    }
    
}

// Y-Axis Class
class YAxis:Axis {
    
    override init(chartBounds: CGRect, gridEnabled: Bool, data:Any) {
        super.init(chartBounds: chartBounds, gridEnabled: gridEnabled, data:data)
        self.major.digits = getMajorDigits()
        self.major.values = getMajorValues()
        self.major.labels = self.major.values.map{$0.styled}
        self.minor.digits = getMinorDigits()
        self.minor.values = getMinorValues()
    }

    var minmax:[Double] { return AxisLimits(data: data).minmax }
    var minY:NumDecomposed { return minmax[0].decomp }
    var maxY:NumDecomposed { return minmax[1].decomp }
    var axisMinMax:[Double] { return AxisLimits(data: data).axisMinMax }

    override func drawLine() {
        makeLine(path: path, fromPoint: origin,
                 toPoint: NSPoint(x: origin.x, y: chartBounds.height - GConstants.chartInsets.top))
        path.stroke()
    }
    
    override func drawTicks() {
        // MajorTicks & Grid
        if major.values != [] {
            majCoords = major.values.map{ getYCoord($0) }
            delta = 5.0
            for i in 0..<majCoords.count {
                makeLine(path: path, fromPoint: NSPoint(x: origin.x - delta, y: majCoords[i]),
                         toPoint: NSPoint(x: origin.x + delta, y: majCoords[i]))
                if gridEnabled == true {
                    makeLine(path: gridPath, fromPoint: NSPoint(x: origin.x + delta, y: majCoords[i]),
                             toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: majCoords[i]))
                }
            }
            path.stroke()
            
            if gridEnabled == true {
                gridPath.lineWidth = 0.1
                gridPath.stroke()
            }
        }
        // MinorTicks & Grid
        minCoords =  minor.values.map{ getYCoord($0) }
        delta = 3.5
        for i in 0..<minCoords.count {
            makeLine(path: path, fromPoint: NSPoint(x: origin.x - delta, y: minCoords[i]),
                     toPoint: NSPoint(x: origin.x + delta, y: minCoords[i]))
            if gridEnabled == true {
                makeLine(path: gridPath, fromPoint: NSPoint(x: origin.x + delta, y: minCoords[i]),
                         toPoint: NSPoint(x: origin.x + xAxisLength*GConstants.tickedAxisSpace, y: minCoords[i]))
            }
        }
        path.stroke()
        if gridEnabled == true {
            gridPath.lineWidth = 0.1
            gridPath.stroke()
        }
    }
    
    override func drawLabels() {
        // Y Major Labels
        var mark:NSString = ""
        var markSize = NSSize()
        var markRect = NSRect()
        delta = 5.0
        if major.labels.count > 0 {
            for i in 0..<major.labels.count {
                mark = major.labels[i] as NSString
                markSize = mark.size(withAttributes: GConstants.markAttributes)
                markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                                  y: majCoords[i] - markSize.height/2,
                                  width : markSize.width, height: markSize.height)
                mark.draw(in: markRect, withAttributes: GConstants.markAttributes)
            }
        }
        
        // Y Minor Labels (Draw zero & Last labels)
        // Zero Label: if decomposed "value before digit" for minimum greater than 8 text labels will be too close -> so ignore minimum label in this case
        let valueLessThenEight = axisMinMax[0].decomp.value <= 8
        if valueLessThenEight {
            mark = axisMinMax[0].styled as NSString
            markSize = mark.size(withAttributes: GConstants.markAttributes)
            markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                              y: origin.y - markSize.height/2,
                              width : markSize.width, height: markSize.height)
            mark.draw(in: markRect, withAttributes: GConstants.markAttributes)
        }
        
        // Last Label
        let lastStrMin = minor.values.last!.styled
        var lastStrMaj = ""
        var lastLabel = ""
        var lastCoord:CGFloat = 0.0
        if major.values != [] {
            lastStrMaj = major.values.last!.styled
            lastLabel = major.values.last! < minor.values.last! ? lastStrMin : lastStrMaj
            lastCoord = major.values.last! < minor.values.last! ? minCoords.last! : majCoords.last!
            if Double(lastLabel) != Double(major.labels.last!) {
                mark = lastLabel as NSString
                markSize = mark.size(withAttributes: GConstants.markAttributes)
                markRect = NSRect(x: origin.x - 3 - delta - markSize.width,
                                  y: lastCoord - markSize.height/2,
                                  width : markSize.width, height: markSize.height)
                mark.draw(in: markRect, withAttributes: GConstants.markAttributes)
            }
        }
    }
    
    override func getAxis() {
        drawLine()
        drawTicks()
        drawLabels()
    }
}

