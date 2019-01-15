//
//  DrawClasses.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 26.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

class Curves:AxisLimits {
    
    var chartTypeName:ChartTypeName
    var currentDopants:[String]
    var xAxisLength:CGFloat
    var yAxisLength:CGFloat
    init(data: Any,chartTypeName:ChartTypeName,currentDopants:[String],xAxisLength:CGFloat,yAxisLength:CGFloat) {
        self.chartTypeName = chartTypeName
        self.currentDopants = currentDopants
        self.xAxisLength = xAxisLength
        self.yAxisLength = yAxisLength
        super.init(data: data)
    }
    
    let origin = GConstants.chartOrigin
    
    private func getCurveCoordinates(_ data:[Double]) ->  [CGPoint] {
        var curveCoords: [CGPoint] = []
        
//        let a = log(axisMinMax[1])
//        let b = log(axisMinMax[0])
        let mult = yAxisLength*GConstants.tickedAxisSpace/(a - b)
        for i in 0..<Constants.g.count {
            let yCoord = origin.y + (CGFloat(log(data[i])) - b)*mult
            let xCoord = CGFloat(Constants.g[i])*xAxisLength*GConstants.tickedAxisSpace + origin.x
            curveCoords.append(CGPoint(x: xCoord, y: CGFloat(yCoord)))
        }
        return curveCoords
    }
        
    func drawMark(markOrigin:NSPoint, dataName:String) {
        let rect = NSRect(origin: markOrigin, size: CGSize(width: 8, height: 8))
        (Constants.dopantsDict[dataName]!.color).setStroke()
        (Constants.dopantsDict[dataName]!.color).setFill()
        if dataName == "B" || dataName == "Al" {
            let oval = NSBezierPath(ovalIn: rect)
            oval.stroke()
        }
        else if dataName == "P" || dataName == "As" {
            let roundRect = NSBezierPath(roundedRect: rect, xRadius: 0, yRadius: 0)
            roundRect.stroke()
            roundRect.fill()
        }
        else {
            let filled = NSBezierPath(ovalIn: rect)
            filled.stroke()
            filled.fill()
        }
    }
    
    private func drawCurve(curveData data:[Double], dataName:String) {
        
        let _curveCoords = LazyBox<[CGPoint]> {
            return self.getCurveCoordinates(data)
        }
        var curveCoords = _curveCoords.value
        
        
        
        let path = NSBezierPath()
        path.lineWidth = 1.5
        (Constants.dopantsDict[dataName]!.color).setStroke()
        
        for i in 0..<Constants.g.count - 1 {
            path.move(to: curveCoords[i])
            path.line(to: curveCoords[i+1])
            if i != 0 && i%15 == 0 && chartTypeName == .DD {
                let figOrigin = NSPoint(x: curveCoords[i].x - 4,
                                        y: curveCoords[i].y - 4)
                drawMark(markOrigin:figOrigin, dataName:dataName)
            }
            path.stroke()
        }
    }
    
    func drawCurves() {
        switch chartTypeName {
        case .DD:
            var dat = data as! [[Double]]
            for i in 0..<currentDopants.count {
                drawCurve(curveData: dat[i], dataName: currentDopants[i])
            }
        case .Net:
            drawCurve(curveData: data as! [Double], dataName: "Net")
        case .Res:
            drawCurve(curveData: data as! [Double], dataName: "Res")
        case .Cmp:
            drawCurve(curveData: data as! [Double], dataName: "Cmp")
        }
    }
    
}
