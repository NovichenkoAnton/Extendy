//
//  Extendy+NSAtrributedString.swift
//  Extendy
//
//  Created by Anton Novichenko on 3/16/20.
//  Copyright © 2020 Anton Novichenko. All rights reserved.
//

import UIKit

public extension NSMutableAttributedString {
	/** Concatinate two attributed strings

		//You can use it with `String` extension
		let result = "123".attributed + "321".attributed
		print(result) // "123321"

	- Parameters:
		- lhs: First attributed string
		- rhs: Second attributed string
	- Returns: Concatinated attributed string
	*/
	static func + (lhs: NSMutableAttributedString, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
		let resultString = NSMutableAttributedString()
		resultString.append(lhs)
		resultString.append(rhs)
		return resultString
	}

	/** Custom attributes for `NSMutableAttributedString`

	- **color**: foregorund color for the string
	- **font**: `UIFont` for the string
	- **crossed**: setup crossed out string with width and color
	- **underline**: apply underline style for the string
	- **url**: setup a link for the string
	- **own**: own attributes for the string
	*/
	enum Attrs {
		case color(color: UIColor = UIColor.black)
		case font(font: UIFont = UIFont.systemFont(ofSize: 16))
		case crossed(width: Int, color: UIColor = UIColor.black)
		case underline(style: NSUnderlineStyle = NSUnderlineStyle.single, color: UIColor = UIColor.black)
		case url(url: String)
		case paragraphStyle(paragraphStyle: () -> NSMutableParagraphStyle)
		case own(attrs: [NSAttributedString.Key : Any] = [:])
	}

	enum Style {
		case sum(integerAttrs: [Attrs] = [], fractionAttrs: [Attrs] = [], currencyMark: String = "")
	}

	/** Apply own attributes for `NSMutableAttributedString`

		//You can use this function for ordinary string, for example:
		let attrString = "123123".attributed.applyAttributes(/*...*/)

	- Parameter attributes: Array of attributes for creating `NSMutableAttributedString`
	- Returns: `NSMutableAttributedString` with attributes applied
	*/
	func applyAttributes(_ attributes: [Attrs]) -> NSMutableAttributedString {
		let range = NSRange(location: 0, length: self.length)

		for attr in attributes {
			switch attr {
			case let .color(color):
				self.addAttribute(.foregroundColor, value: color, range: range)
			case let .font(font):
				self.addAttribute(.font, value: font, range: range)
			case let .crossed(width, color):
				self.addAttribute(.strikethroughStyle, value: width, range: range)
				self.addAttribute(.strikethroughColor, value: color, range: range)
			case let .underline(style, color):
				self.addAttribute(.underlineStyle, value: style.rawValue, range: range)
				self.addAttribute(.underlineColor, value: color, range: range)
			case let .url(url):
				if let link = NSURL(string: url) {
					self.addAttribute(.link, value: link, range: range)
				}
			case let .paragraphStyle(paragraphStyle):
				self.addAttribute(.paragraphStyle, value: paragraphStyle(), range: range)
			case let .own(attrs):
				self.addAttributes(attrs, range: range)
			}
		}

		return self
	}

	/** Apply style for specific string with specific `Style`

		let result1 = "12333,33".attributed.applyStyle(.sum(integerAttrs:
		[
		  .color(color: UIColor.red)
		],
		fractionAttrs:
		[
		  .color(color: UIColor.yellow)
		], currencyMark: "$"))
		print(result1) //12 333,33$

	- Parameter style: `Style` for formatting
	- Returns: Fromatted attributted string
	*/
	func applyStyle(_ style: Style) -> NSMutableAttributedString {
		switch style {
		case let .sum(integerAttrs, fractionAttrs, currencyMark):
			return attributeSum(integerAttrs: integerAttrs, fractionAttrs: fractionAttrs, currencyMark: currencyMark)
		}
	}

	/** Create an attributed string with an amount style with attributes for integer part and fraction part of the string. A devider is styled with fraction attributes, a currency mark is styled with attributes for fraction part, if fraction attributes are empty, the currency mark will be styed with attributes for integer part.


	- Parameters:
	  - integerAttrs: Attributes for integer part
	  - fractionAttrs: Attributes for fraction part
	  - currencyMark: Currency mark if needed
	- Returns: Formatted `NSMutableAttributedString`
	*/
	private func attributeSum(integerAttrs: [Attrs], fractionAttrs: [Attrs], currencyMark: String) -> NSMutableAttributedString {
		var currency = NSMutableAttributedString(string: currencyMark)
		var separator = NSMutableAttributedString(string: "")
		
		let parts = self.string.ext.applyFormat(.sum(minFractionDigits: 0, maxFractionDigits: 2)).components(separatedBy: defaultSeparator.string)

		var integerPart = ""
		var fractionPart = ""

		if parts.count == 2 {
			integerPart = parts.first!
			fractionPart = parts.last!

			separator = defaultSeparator.applyAttributes(fractionAttrs)
		} else {
			integerPart = parts.first!
		}

		var integerAttributed = NSMutableAttributedString(string: integerPart)
		var fractionAttributed = NSMutableAttributedString(string: fractionPart)

		if !integerPart.isEmpty && !integerAttrs.isEmpty {
			integerAttributed = integerPart.attributed.applyAttributes(integerAttrs)
		}

		if !fractionPart.isEmpty && !fractionAttrs.isEmpty {
			fractionAttributed = fractionPart.attributed.applyAttributes(fractionAttrs)
		}

		currency = currencyMark.trim().attributed.applyAttributes(fractionAttrs)

		return integerAttributed + separator + fractionAttributed + currency
	}
}

private extension NSMutableAttributedString {
	/// Possible separators for amount strings
	private var separators: CharacterSet {
		CharacterSet(charactersIn: ",.")
	}

	/// Default separator for sum strings
	private var defaultSeparator: NSMutableAttributedString {
		",".attributed
	}

	/// Trim attributed string
	func trim() -> NSAttributedString {
		let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
		let startRange = string.rangeOfCharacter(from: invertedSet)
		let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
		guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
			return NSAttributedString(string: string)
		}
		let location = string.distance(from: string.startIndex, to: startLocation) - 1
		let length = string.distance(from: startLocation, to: endLocation) + 2
		let range = NSRange(location: location, length: length)
		return attributedSubstring(from: range)
	}
}

// MARK: - NSAttributedString + HTML

public extension NSAttributedString {
	/// Render HTML string and returns styled NSAttributedString
	/// - Parameter htmlString: String with HTML tags
	convenience init?(htmlString: String) {
		guard let data = htmlString.data(using: .utf16) else { return nil }

		let options: [DocumentReadingOptionKey : Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		]

		guard let string = try? NSMutableAttributedString(
				data: data,
				options: options,
				documentAttributes: nil) else { return nil }

		self.init(attributedString: string.trim())
	}

	/// Render HTML string and return styled NSAttributedString
	/// - Parameters:
	///   - htmlString: String with HTML tags
	///   - fontSize: Font size
	///   - foregroundColor: Foregroung color
	convenience init?(htmlString: String, fontSize: CGFloat, foregroundColor: UIColor = UIColor.black) {
		let htmlTemplate = """
			<!doctype html>
			<html>
			  <head>
				<style>
				  body {
					font-family: -apple-system;
					font-size: \(fontSize)px;
					color: \(foregroundColor.hexString);
				  }
				</style>
			  </head>
			  <body>
				\(htmlString)
			  </body>
			</html>
		"""

		self.init(htmlString: htmlTemplate)
	}
}
