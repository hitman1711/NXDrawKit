//
//  Palette.swift
//  NXDrawKit
//
//  Created by Nicejinux on 2016. 7. 12..
//  Copyright © 2016년 Nicejinux. All rights reserved.
//

import UIKit

@objc public protocol PaletteDelegate
{
    @objc optional func didChangeBrushAlpha(_ alpha:CGFloat)
    @objc optional func didChangeBrushWidth(_ width:CGFloat)
    @objc optional func didChangeBrushColor(_ color:UIColor)
    
    @objc optional func colorWithTag(_ tag: NSInteger) -> UIColor?
    @objc optional func alphaWithTag(_ tag: NSInteger) -> CGFloat
    @objc optional func widthWithTag(_ tag: NSInteger) -> CGFloat
}


open class Palette: UIView
{
    @objc open weak var delegate: PaletteDelegate?
    fileprivate var brush: Brush = Brush()
	private static var lessScreenSide: CGFloat {  return min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)  }
	
	fileprivate static let buttonDiameter: CGFloat  = lessScreenSide / 12.0
	fileprivate static let buttonPadding: CGFloat = lessScreenSide / 35.0
    fileprivate static let columnCount = 6
    
    fileprivate var colorButtonList = [CircleButton]()
    fileprivate var alphaButtonList = [CircleButton]()
    fileprivate var widthButtonList = [CircleButton]()
    
    fileprivate var totalHeight: CGFloat = 0.0;
    
    fileprivate weak var colorPaletteView: UIView?
    fileprivate weak var alphaPaletteView: UIView?
    fileprivate weak var widthPaletteView: UIView?
    
    // MARK: - Public Methods
    public init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc open func currentBrush() -> Brush {
        return self.brush
    }
    

    // MARK: - Private Methods
    override open var intrinsicContentSize : CGSize {
        let size: CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.totalHeight)
        return size;
    }
    
    @objc open func setup() {
        self.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.21, alpha: 1.0)
        self.setupColorView()
        self.setupAlphaView()
        self.setupWidthView()
        self.setupDefaultValues()
    }
    
    @objc open func paletteHeight() -> CGFloat {
        return self.totalHeight
    }
	
	public func selectColorButton(at index: Int) {
		guard self.colorButtonList.count > index else {  return  }
		self.onClickColorPicker(self.colorButtonList[index])
	}
	
	public static var precalcPaletteHeight: CGFloat {
		let lastButtonFrame =  self.buttonRect(index: 12, diameter: buttonDiameter, padding: buttonPadding, columns: columnCount)
		return lastButtonFrame.maxY + buttonPadding
	}
    
    fileprivate func setupColorView() {
        let view = UIView()
        self.addSubview(view)
        self.colorPaletteView = view
        
        var button: CircleButton?
        for index in 1...12 {
            let color: UIColor = self.color(index)
            button = CircleButton(diameter: Palette.buttonDiameter, color: color, opacity: 1.0)
            button!.frame = Palette.buttonRect(index: index, diameter: Palette.buttonDiameter, padding: Palette.buttonPadding, columns: Palette.columnCount)
			
            button!.addTarget(self, action:#selector(Palette.onClickColorPicker(_:)), for: .touchUpInside)
            self.colorPaletteView!.addSubview(button!)
            self.colorButtonList.append(button!)
        }
        
        self.totalHeight = button!.frame.maxY + Palette.buttonPadding;
        self.colorPaletteView!.frame = CGRect(x: 0, y: 0,
											  width: button!.frame.maxX + Palette.buttonPadding,
											  height: self.totalHeight)
    }
	
	fileprivate static func buttonRect(index: NSInteger, diameter: CGFloat, padding: CGFloat, columns: Int) -> CGRect {
		var rect: CGRect = CGRect.zero
		let indexValue = index - 1
		let columnIdx = CGFloat(indexValue % columns)
		let buttonInnerSpacing = ((Palette.buttonDiameter - diameter) / 2)
		rect.origin.x = (columnIdx * diameter) + padding + (columnIdx * padding) + buttonInnerSpacing
		rect.origin.y = (CGFloat(indexValue / columns) * diameter) + padding + (CGFloat(indexValue / columns) * padding) + buttonInnerSpacing
		rect.size = CGSize(width: diameter, height: diameter)
		
		return rect
	}
    
    fileprivate func setupAlphaView() {
        let view = UIView()
        self.addSubview(view)
        self.alphaPaletteView = view
        
        var button: CircleButton?
		var maxX: CGFloat?
        for index in (1...3).reversed() {
            let opacity = self.opacity(index)
            button = CircleButton(diameter: Palette.buttonDiameter, color: UIColor.black, opacity: opacity)
            button!.frame = Palette.buttonRect(index: index, diameter: Palette.buttonDiameter, padding: Palette.buttonPadding, columns: 3)
			
			maxX = maxX == nil ? button!.frame.maxX : max(maxX!, button!.frame.maxX)
            self.alphaPaletteView!.addSubview(button!)
            button!.addTarget(self, action: #selector(Palette.onClickAlphaPicker(_:)), for: .touchUpInside)
            self.alphaButtonList.append(button!)
        }
	
		let paletteWidth = maxX! + Palette.buttonPadding
		
		let startX = UIScreen.main.bounds.width - paletteWidth - (2 * Palette.buttonPadding)
		
        self.alphaPaletteView!.frame = CGRect(x: startX, y: 0,
											  width: paletteWidth,
											  height: Palette.buttonPadding + Palette.buttonDiameter)
    }
    

    fileprivate func setupWidthView() {
        let view = UIView()
        self.addSubview(view)
        self.widthPaletteView = view
        
        var button: CircleButton?
		var lastX: CGFloat = 4
		
        for index in 1...4 {
            let buttonDiameter = self.brushWidth(index)
            button = CircleButton(diameter: buttonDiameter, color: UIColor.black, opacity: 1)
			button!.frame = Palette.widthButtonRect(index: index, diameter: buttonDiameter, padding: Palette.buttonPadding, columns: 4, lastX: lastX)
			lastX = button!.frame.maxX
            self.widthPaletteView!.addSubview(button!)
            button!.addTarget(self, action: #selector(Palette.onClickWidthPicker(_:)), for: .touchUpInside)

            self.widthButtonList.append(button!)
        }
		
		let paletteWidth = lastX + Palette.buttonPadding
		let startX = UIScreen.main.bounds.width - paletteWidth - (2 * Palette.buttonPadding)
//        let startX = self.alphaPaletteView!.frame.minX
		let startY = self.alphaPaletteView!.frame.maxY
		
        self.widthPaletteView!.frame = CGRect(x: startX, y: startY,
											  width: paletteWidth,
											  height: Palette.buttonPadding + Palette.buttonDiameter)
    }
	
	fileprivate static func widthButtonRect(index: NSInteger, diameter: CGFloat, padding: CGFloat, columns: Int, lastX: CGFloat) -> CGRect {
		var rect: CGRect = CGRect.zero
		let indexValue = index - 1
		let buttonInnerSpacing = ((Palette.buttonDiameter - diameter) / 2)
		rect.origin.x = lastX + padding + buttonInnerSpacing
		rect.origin.y = (CGFloat(indexValue / columns) * diameter) + padding + (CGFloat(indexValue / columns) * padding) + buttonInnerSpacing
		rect.size = CGSize(width: diameter, height: diameter)
		
		return rect
	}
	
    fileprivate func setupDefaultValues() {
        var button: CircleButton = self.colorButtonList.first!
        button.isSelected = true
        self.brush.color = button.color!
        
        button = self.alphaButtonList.first!
        button.isSelected = true
        self.brush.alpha = button.opacity!
        
        button = self.widthButtonList.last!
        button.isSelected = true
        self.brush.width = button.diameter!
    }
    
    @objc fileprivate func onClickColorPicker(_ button: CircleButton) {
        self.brush.color = button.color!;
        let shouldEnable = !self.brush.color.isEqual(UIColor.clear)

        self.resetButtonSelected(self.colorButtonList, button: button)
        self.updateColorOfButtons(self.widthButtonList, color: button.color!)
        self.updateColorOfButtons(self.alphaButtonList, color: button.color!, enable: shouldEnable)
        
        self.delegate?.didChangeBrushColor?(self.brush.color)
    }

    @objc fileprivate func onClickAlphaPicker(_ button: CircleButton) {
        self.brush.alpha = button.opacity!
        self.resetButtonSelected(self.alphaButtonList, button: button)
        
        self.delegate?.didChangeBrushAlpha?(self.brush.alpha)
    }

    @objc fileprivate func onClickWidthPicker(_ button: CircleButton) {
        self.brush.width = button.diameter!;
        self.resetButtonSelected(self.widthButtonList, button: button)
        
        self.delegate?.didChangeBrushWidth?(self.brush.width)
    }
    
    fileprivate func resetButtonSelected(_ list: [CircleButton], button: CircleButton) {
        for aButton: CircleButton in list {
            aButton.isSelected = aButton.isEqual(button)
        }
    }
    
    fileprivate func updateColorOfButtons(_ list: [CircleButton], color: UIColor, enable: Bool = true) {
        for aButton: CircleButton in list {
            aButton.update(color)
            aButton.isEnabled = enable
        }
    }
    
    fileprivate func color(_ tag: NSInteger) -> UIColor {
        if let color = self.delegate?.colorWithTag?(tag)  {
            return color
        }

        return self.colorWithTag(tag)
    }
    
    fileprivate func colorWithTag(_ tag: NSInteger) -> UIColor {
		switch(tag) {
		case 1: return UIColor.white
		case 2: return UIColor.gray
		case 3: return UIColor.darkGray
		case 4: return UIColor.black
		case 5: return UIColor(red: 0.62, green: 0.32, blue: 0.17, alpha: 1.0) // Brown
		case 6: return UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)	// Red
		case 7: return UIColor.orange
		case 8: return UIColor.yellow
		case 9: return UIColor(red: 0.15, green: 0.47, blue: 0.23, alpha: 1.0) // Dark green
		case 10: return UIColor.green
		case 11: return UIColor(red: 0.2, green: 0.3, blue: 1.0, alpha: 1.0)	// Dark blue
		case 12: return UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0)	// Blue
		default: return UIColor.black
		}
    }
    
    fileprivate func opacity(_ tag: NSInteger) -> CGFloat {
        if let opacity = self.delegate?.alphaWithTag?(tag) {
            if 0 > opacity || opacity > 1 {
                return CGFloat(tag) / 3.0
            }
            return opacity
        }

        return CGFloat(tag) / 3.0
    }

    fileprivate func brushWidth(_ tag: NSInteger) -> CGFloat {
        if let width = self.delegate?.widthWithTag?(tag) {
            if 0 > width || width > Palette.buttonDiameter {
                return Palette.buttonDiameter * (CGFloat(tag) / 4.0)
            }
            return width
        }
        return Palette.buttonDiameter * (CGFloat(tag) / 4.0)
    }
}
