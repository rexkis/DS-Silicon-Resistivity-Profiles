//
//  GraphView.swift
//  SiH_TT
//
//  Created by Igor Kutovoy on 25.05.17.
//  Copyright © 2017 Igor Kutovoy. All rights reserved.
//

import Cocoa

class GConstants {
    let stringMaker = StringMaker()
    static let fontName = "Helvetica-Light"
    static let chartTitle = ["DOPANT DENSITIES DISTRIBUTION",
                             "NET DENSITY DISTRIBUTION",
                             "SPECIFIC RESISTIVITY DISTRIBUTION",
                             "COMPENSATION LEVEL DISTRIBUTION"]
    static let yAxisTitle = ["Dopant Density, (at/cm3)", "Net Density, (at/cm3)", "Resistivity, (Ohm∙cm)","Compensation level"]
    
    static let chartOrigin = NSPoint(x: 65, y: 50)
    static var chartInsets: (left:CGFloat, top:CGFloat, right:CGFloat, bottom:CGFloat ) {
        return (chartOrigin.x,100,40,chartOrigin.y)
    }
    static let tickedAxisSpace:CGFloat = 0.98
    
//    static var parStyle:NSMutableParagraphStyle {
//        self.parStyle.lineBreakMode = .byTruncatingTail
//        self.parStyle.alignment = .center
//        return self.parStyle
//    }
    static var markAttributes: [NSAttributedStringKey: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        return  [NSAttributedStringKey.font: NSFont(name: fontName, size: 12)!,
                 NSAttributedStringKey.foregroundColor: NSColor.black,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle]
    }
    static let xMarkSize:NSSize = ("0.1" as NSString).size(withAttributes: markAttributes)
    
    static let pTypeColor = NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.05)
    static let nTypeColor = NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 0.05)
    
}

class GraphView: NSView {
    
    // MARK: XIB Initialization
    @IBOutlet var contentView: NSView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "GraphView"), owner: self, topLevelObjects: nil)
        
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.width,.height]
        self.addSubview(content)
    }
    
    // MARK: Title & Subtitles
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var customLabel: NSTextField!
    @IBOutlet weak var calculatedLabel: NSTextField!
    var titleLabelText:String = "" {
        didSet { titleLabel.stringValue = titleLabelText }
    }
    var customLabelText:NSMutableAttributedString = "".attr() {
        didSet { customLabel.attributedStringValue = customLabelText }
    }
    var calculatedLabelText:NSMutableAttributedString = "".attr() {
        didSet { calculatedLabel.attributedStringValue = calculatedLabelText }
    }
    
    // Labels for Axes names
    @IBOutlet weak var yAxisLabel: NSTextField!
    @IBOutlet weak var xAxisLabel: NSTextField!
    var yAxisTitle: NSMutableAttributedString = "".attr() {
        didSet { yAxisLabel.attributedStringValue = yAxisTitle }
    }
    
    // MARK: ChartTypeIndex and selecting current yData for Chart
    var chartTypeIndex:Int = 0
    var chartTypeName:ChartTypeName = .Res
    {
        didSet {
            switch chartTypeName {
            case .DD:
                chartTypeIndex = 0
                yData = ingotData!.dopDist as AnyObject
            case .Net:
                chartTypeIndex = 1
                yData = ingotData!.netDist[1] as AnyObject
            case .Res:
                chartTypeIndex = 2
                yData = ingotData!.resDist as AnyObject
            case .Cmp:
                chartTypeIndex = 3
                yData = ingotData!.comp as AnyObject
            }
            setTitles(index: chartTypeIndex)
        }
    }
    
    // MARK: Data from ViewController
    var currentDopants:[String] = []
    var ingotData: Distributions?
    var negRange: [Int]?
    
    let xData = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]  
    var yData: AnyObject?
    
    // MARK: Chart axis lengths
    var xAxisLength:CGFloat = 0
    var tickedXLength:CGFloat {return xAxisLength*GConstants.tickedAxisSpace}
    var yAxisLength:CGFloat = 0
    var tickedYLength:CGFloat {return yAxisLength*GConstants.tickedAxisSpace}
    
//    let graphViewRect:NSRect = self.convert(self.bounds, to: nil)
    
    var curves:Curves?
    
    var context:CGContext?
    var needsToRedraw:Bool = false
    
    var yGridEnabled = false {
        didSet { needsDisplay = true }
    }
    var xGridEnabled = false {
        didSet { needsDisplay = true }
    }
    var fillPNAreas:Bool = false {
        didSet { needsDisplay = true }
    }
    var trackEnabled:Bool = false {
        didSet { needsDisplay = true }
    }
    
    // Axes Drawing Parameters
    let origin = GConstants.chartOrigin
    
    // Tracking parameters
    var trackXPath = NSBezierPath()
    var xPosition:CGFloat = 0
    var yPosition:CGFloat = 0
    var currentTrackPoint:NSPoint = NSPoint.zero
    var gValue:Double = 0.0
    
    var trackingRect: NSRect {
        return NSRect(x: origin.x,
                      y: origin.y,
                      width: tickedXLength*0.99,
                      height: tickedYLength)
    }
    var trackView:NSView {return NSView(frame: trackingRect)}
    var trackNote:String {return getTrackValueNote()}
    
    override func viewWillDraw() {
        setTitles(index:chartTypeIndex)
        yAxisLabel.frameCenterRotation = 90
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 10.0
    }
    
//    func setTitles(index:Int) {
//        titleLabelText = GConstants.chartTitle[index]
//        yAxisTitle = GConstants.yAxisTitle[index].attr()
//    }
    func setTitles(index:Int) {
        titleLabelText = GConstants.chartTitle[chartTypeIndex]
        yAxisTitle = GConstants.yAxisTitle[chartTypeIndex].attr()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        context = NSGraphicsContext.current?.cgContext
        
        yAxisLength = bounds.height - origin.y - GConstants.chartInsets.top
        xAxisLength = bounds.width - origin.x - GConstants.chartInsets.right
        
        if needsToRedraw == true {
            clearGraphView()
            needsToRedraw = false
        }
        else {
            drawChart()
        }
    }
    
    func drawChart() {
        for v in subviews {
            v.isHidden = false
        }

        // Draw axes with ticks and labels using Axes.swift class
        let xAxis = XAxis(chartBounds: bounds, gridEnabled: xGridEnabled, data: xData)
        let yAxis = YAxis(chartBounds: bounds, gridEnabled: yGridEnabled, data: yData ?? [])
        xAxis.getAxis()
        yAxis.getAxis()

        curves = Curves(data: yData!, chartTypeName: chartTypeName, currentDopants: currentDopants, xAxisLength: xAxisLength, yAxisLength: yAxisLength)
        curves!.drawCurves()
        
        if fillPNAreas == true {
            drawPNAreas()
        }
        if chartTypeIndex == 0 {
            drawLegend(dopants: currentDopants)
        }
        if trackEnabled == true {
            drawTrackMark()
            drawTrackingLines()
        }
        else {
            needsDisplay = true
        }
        
    }

    override func mouseDown(with event: NSEvent) {
        guard trackEnabled == true else {return}
        currentTrackPoint = getTrackPoint(point: event.locationInWindow)
        
        getCurrentTouch()
        needsDisplay = true
    }
    override func mouseDragged(with event: NSEvent) {
        guard trackEnabled == true else {return}
        currentTrackPoint = getTrackPoint(point: event.locationInWindow)
        
        getCurrentTouch()
        needsDisplay = true
    }
    func getCurrentTouch() {
        // Проверяем принадлежность текущей точки trackView. Если нет - выход (надо удалить предыдущее, если есть)
        let inRange = trackView.bounds.contains(currentTrackPoint)
        guard inRange == true else {return}
        
        // Normalize x coordinates according g-value (step = 0.01)
        let normG = currentTrackPoint.x/tickedXLength
        gValue = Double(normG.roundTo(0.01))
    }
     
    func clearGraphView() {
        context!.clear(self.bounds)
        for v in subviews {
            v.isHidden = true
        }
    }
    
    func toPDF() {
        let savePanel = NSSavePanel()
        savePanel.title = "Save PDF File"
        savePanel.message = "Enter filename without extension"
        savePanel.allowedFileTypes = ["pdf"]
        savePanel.nameFieldStringValue = "SamplePDFFile"
        savePanel.nameFieldLabel = "PDF name:"
        
        // Мой вариант сохранения
        //        savePanel.begin(completionHandler: { (result:Int) -> Void in
        //            if result == NSFileHandlingPanelOKButton {
        //                //                let exportedFileURL = (savePanel.url)?.appendingPathExtension("pdf")
        //                let exportedFileURL = (savePanel.url)
        //                Swift.print("Saving to \(String(describing: exportedFileURL))")
        //                let vBounds = self.frame
        //
        //                let pdfData = self.dataWithPDF(inside: vBounds)
        //                try? pdfData.write(to: exportedFileURL!)
        //            }
        //        })
        
        // Вариант сохранения по Ray Wenderlich. Catch вызывается, если здесь у оператора try НЕ СТАВИМ вопросительный знак, ?
        guard let window = self.window else { return }
        savePanel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                do {
                    let exportedFileURL = (savePanel.url)
                    Swift.print("Saving to \(String(describing: exportedFileURL))")
                    let vBounds = self.frame
                    
                    let pdfData = self.dataWithPDF(inside: vBounds)
                    try pdfData.write(to: exportedFileURL!)
                } catch {
                    self.showErrorDialogIn(window: window,
                                           title: "Unable to save file",
                                           message: error.localizedDescription)
                }
            }
        }
    }
    // From RW
    func showErrorDialogIn(window: NSWindow, title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
}
