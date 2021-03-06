//
//  Extendy+String.swift
//  Extendy
//
//  Created by Anton Novichenko on 3/12/20.
//  Copyright © 2020 Anton Novichenko. All rights reserved.
//

import UIKit
import Contacts

extension String: ExtendyCompatible {}

public extension String {
	/// String formats
	enum Format {
		case sum(minFractionDigits: Int = 2, maxFractionDigits: Int = 2)
		case creditCard
		case iban
		case custom(formatter: NumberFormatter)
	}

	/// Pattern for validating string
	enum RegExpPattern {
		case email
		case phoneBY
		case website
		case own(pattern: String)
	}

	/// Computed property which create `NSMutableAttributedString` from `String`
	var attributed: NSMutableAttributedString {
		NSMutableAttributedString(string: self)
	}

	/// Computed property which returns `Data` from the string with `utf8` encoding
	var data: Data {
		self.data(using: .utf8).orEmpty
	}

	/// Computed property which return digits from the string
	var digits: String {
		self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
	}

	/// Returns double value of string,
	/// if a value is not compatible with `Double` - returns `.zero`
	func toDouble() -> Double {
		var mutatingString = self.trim().components(separatedBy: .whitespaces).joined(separator: "")

		if self.contains(",") {
			mutatingString = mutatingString.replacingOccurrences(of: ",", with: ".")
		}

		return Double(mutatingString) ?? .zero
	}

	/// Returns integer value of string
	/// if a value is not compatible with `Int` - returns 0
	func toInt() -> Int {
		Int(self) ?? 0
	}

	/**
	Detect if the string contains only numeric symbols

	- Returns: `true` if the string contains only decimal digits
	*/
	func hasOnlyDigits() -> Bool {
		guard !isEmpty else { return false }

		return !contains(where: { !$0.isNumber })
	}

	/// Remove whitespaces and new lines from both ends of `String`
	func trim() -> String {
		self.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	/// Separate the string with a separator set
	/// - Parameters:
	///   - stride: Index for a separator
	///   - separator: Seaprator character for deviding the string
	func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        let characters = enumerated().map {
			$0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]
		}

		return String(characters.joined())
    }

	/** Returns a size for the string with specific width and font

	- Parameters:
		- width: Width for container
		- font: Specific font for string
	- Returns: Size for the string inside containter
	*/
	func size(width: CGFloat, font: UIFont = .systemFont(ofSize: 16)) -> CGSize {
		guard !isEmpty else {
			return CGSize(width: width, height: .zero)
		}

		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
		return boundingBox.size
	}

	/** Mask substring in `CountableRange` with specific character

		if let string = "abcdefg".maskSubstring(in: 5..<7, with: "*") {
		  print(string) //"abcde**"
		}

	- Parameters:
		- range: `CountableRange` for substring changes
		- maskSymbol: Symbol which masks substring in range
	- Returns: Masked string
	*/
	func maskSubstring(in range: CountableRange<Int>, with maskSymbol: Character) -> String? {
		guard range.upperBound <= self.count else {
			return nil
		}

		let maskString = String(repeating: maskSymbol, count: range.upperBound - range.lowerBound)

		let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)

		return self.replacingCharacters(in: startIndex..<endIndex, with: maskString)
	}

	/** Mask substring in `ClosedRange` with specific character

		if let string = "abcdefg".maskSubstring(in: 5...6, with: "*") {
		  print(string) //"abcde**"
		}

	- Parameters:
		- range: `ClosedRange` for substring changes
		- maskSymbol: Symbol which masks a substring in range
	- Returns: Masked string
	*/
	func maskSubstring(in range: ClosedRange<Int>, with maskSymbol: Character) -> String? {
		guard range.upperBound < self.count else {
			return nil
		}

		let maskString = String(repeating: maskSymbol, count: (range.upperBound - range.lowerBound) + 1)

		let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)

		return self.replacingCharacters(in: startIndex...endIndex, with: maskString)
	}

	/** Mask substring in `PartialRangeFrom` with specific character

		if let string = "abcdefg".maskSubstring(in: 5..., with: "*") {
		  print(string) //"abcde**"
		}

	- Parameters:
		- range: `PartialRangeFrom` for substring changes
		- maskSymbol: Symbol which masks a substring in range
	- Returns: Masked string
	*/
	func maskSubstring(in range: PartialRangeFrom<Int>, with maskSymbol: Character) -> String? {
		guard range.lowerBound < self.count else {
			return nil
		}

		let maskString = String(repeating: maskSymbol, count: self.count - range.lowerBound)

		let index = self.index(self.startIndex, offsetBy: range.lowerBound)

		return self.replacingCharacters(in: index..., with: maskString)
	}

	/** Mask substring in `PartialRangeThrough` with specific character

		if let string = "abcdefg".maskSubstring(in: ...2, with: "*") {
		  print(string) //"***defg"
		}

	- Parameters:
		- range: `PartialRangeThrough` for substring changes
		- maskSymbol: Symbol which masks a substring in range
	- Returns: Masked string
	*/
	func maskSubstring(in range: PartialRangeThrough<Int>, with maskSymbol: Character) -> String? {
		guard range.upperBound < self.count else {
			return nil
		}

		let maskString = String(repeating: maskSymbol, count: range.upperBound + 1)

		let index = self.index(self.startIndex, offsetBy: range.upperBound)

		return self.replacingCharacters(in: ...index, with: maskString)
	}

	/** Mask substring in `PartialRangeUpTo` with specific character

		if let string = "abcdefg".maskSubstring(in: ..<2, with: "*") {
		  print(string) //"**cdefg"
		}

	- Parameters:
		- range: `PartialRangeUpTo` for substring changes
		- maskSymbol: Symbol which masks a substring in range
	- Returns: Masked string
	*/
	func maskSubstring(in range: PartialRangeUpTo<Int>, with maskSymbol: Character) -> String? {
		guard range.upperBound <= self.count else {
			return nil
		}

		let maskString = String(repeating: maskSymbol, count: range.upperBound)

		let index = self.index(self.startIndex, offsetBy: range.upperBound)

		return self.replacingCharacters(in: ..<index, with: maskString)
	}

	/** Validate credit card with Luhn algorithm

	- Throws: `StringifyError.invalidCard`
			if card didn't pass through Luhn algorithm
	- Returns: `true` if card is valid
	*/
	func validateCreditCard() -> Bool {
		let preparedString = self.trim().components(separatedBy: .whitespaces).joined(separator: "")

		guard luhnAlgorithm(preparedString) else { return false }

		return true
	}

	/** Check the string for the presence of data of the VCard format

	- Returns: `true` if the string contains VCard data
	*/
	func hasVCardData() -> Bool {
		guard let vcardData = data(using: .utf16) else { return false }

		do {
			return try !CNContactVCardSerialization.contacts(with: vcardData).isEmpty
		} catch {
			return false
		}
	}

	/** Returns `Dictionary` of queryItems from the string (if it compatible with `URL`). It works for URLs with cyrillic domain name.

		if let queryItems = "https://test.com?foo=1&bar=abc".queryItems() {
		  print(queryItems) //["foo": "1", "bar": "abc"]
		}

	- Returns: `Dictionary` of query items
	*/
	func queryItems() -> [String: String]? {
		guard let scheme = matches(with: "(https|http)://").first else {
			return nil
		}

		guard let host = self.replacingOccurrences(of: scheme, with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			return nil
		}

		guard let components = URLComponents(string: host) else {
			return nil
		}

		var items: [String: String] = [:]

		components.queryItems?.forEach {
			items[$0.name] = $0.value?.removingPercentEncoding
		}

		return items
	}

	/** Finds matches inside string by regular expression

	- Parameters:
	  - regex: Regular expression
	  - options: The regular expression options that are applied to the expression during matching
	- Returns: Arrat of matches in the string
	*/
	func matches(with regex: String, for options: NSRegularExpression.Options = [.caseInsensitive]) -> [String] {
		let regularExpression: NSRegularExpression
		do {
			regularExpression = try NSRegularExpression(pattern: regex, options: options)
		} catch {
			return []
		}

		let range = NSRange(location: 0, length: self.utf16.count)
		let results = regularExpression.matches(in: self, range: range)

		return results.compactMap {
			self.substring(with: $0.range)
		}
	}

	/** Returns substring (type `String`) in `NSRange`

	- Parameter nsRange: NSRange
	- Returns: The string inside `NSRange`
	*/
	func substring(with nsRange: NSRange) -> String? {
		guard let range = Range(nsRange, in: self) else {
			return nil
		}

		return String(self[range])
	}

	/** Validate the string with chosen pattern

	- Parameters:
		- pattern: Prepared `RegExpPattern` for validating
		- options: The regular expression options that are applied to the expression during matching
	*/
	func validate(with pattern: RegExpPattern, for options: NSRegularExpression.Options = [.caseInsensitive]) -> Bool {
		let regularExpression: NSRegularExpression
		do {
			regularExpression = try NSRegularExpression(pattern: invokeRegularExpression(for: pattern), options: options)
		} catch {
			return false
		}

		let range = NSRange(location: 0, length: self.utf16.count)
		return regularExpression.firstMatch(in: self, range: range) != nil
	}

	/** Fetch regular expression for specific pattern

	- Parameter pattern: `RegExpPattern`
	- Returns: Regular expression
	*/
	private func invokeRegularExpression(for pattern: RegExpPattern) -> String {
		switch pattern {
		case .email:
			return "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
		case .phoneBY:
			return "^\\+[0-9]{1,12}$"
		case .website:
			return "((http|https)://)?([(w|W)]{3}+\\.)?(.)\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
		case let .own(pattern):
			return pattern
		}
	}
}


public extension Extendy where Base == String {
	/** Returns new string which was made by applying `Format`.

		// .sum
		let string = "1234".ext.applyFormat(.sum())
		print(string) //"1 234,00"

		//.creditCard
		let string = "1234567890123456".ext.applyFormat(.creditCard)
		print(string) //1234 5678 9012 3456

		//Or you can use own formatter
		let string = "1234".ext.applyFormat(.custom(formatter: ownNumberFormatter))

	- Parameter format: Format of new string
	- Returns: Formatted string
	*/
	func applyFormat(_ format: Base.Format) -> String {
		switch format {
		case let .sum(minFractionDidigts, maxFractionDigits):
			return triadString(self.ext, minFractionDigits: minFractionDidigts, maxFractionDigits: maxFractionDigits)
		case .creditCard:
			return creditCardString(self.ext)
		case .iban:
			return ibanString(self.ext)
		case let .custom(formatter):
			return formatString(self.ext, with: formatter)
		}
	}

	/** Remove whitespaces and new lines from both ends, remove whitepsaces inside the string and replace `decimalSeparator` from `,` to `.` using inner `NumberFormatter`. This string suitable as a parameter for network requests e.g. money fields.

		let string = "1 234,56".ext.clean()
		print(string) //"1234.56"

		let anotherString = "1 234".ext.clean()
		print(anotherString) //"1234.00"

	- Parameters:
		- minFractionDigits: Min number of fraction digits after separator. Default value is 2
		- maxFractionDigits: Max number of fraction digits after separator. Default value is 2
		- groupingSeparator: Separator between digits in an integer part. Default value is " "
		- decimalSeparator: Separator between an integer part and a fraction part. Default value is `,`.

	- Returns: Formatted string without inner grouping separatorss and with decimal separator (.).
	*/
	func clean(minFractionDigits: Int = 2, maxFractionDigits: Int = 2, groupingSeparator: String = " ", decimalSeparator: String = ",") -> String {
		cleanNumberFormatter.minimumFractionDigits = minFractionDigits
		cleanNumberFormatter.maximumFractionDigits = maxFractionDigits

		let formatted = self.ext
			.trim()
			.components(separatedBy: groupingSeparator)
			.joined()
			.replacingOccurrences(of: decimalSeparator, with: ".")
			.toDouble()
		return cleanNumberFormatter.string(from: NSNumber(value: formatted)) ?? String(Double.zero)
	}

	/** Convert string between date formats

		let time = "2019-11-22 12:33".ext.convertDate(from: "yyyy-MM-dd HH:mm", to: "HH:mm")
		print(time) //"12:33"

	- Parameters:
		- fromFormat: Input date format
		- toFormat: Result date format
	- Returns: Converted string with result format
	*/
	func convertDate(from fromFormat: String, to toFormat: String, locale: Locale = Locale.current) -> String? {
		dateFormatter.dateFormat = fromFormat
		dateFormatter.locale = locale

		let tmpDate = dateFormatter.date(from: self.ext)
		dateFormatter.dateFormat = toFormat

		guard let date = tmpDate else {
			return nil
		}

		return dateFormatter.string(from: date)
	}
}

private extension Extendy where Base == String {
	/// Default value is "0,00"
	static var defaultValue: String {
		"0,00"
	}

	/// Make triad format for string, i.e. from "1234" it makes "1 234"
	/// - Parameter string: String for formatting
	/// - Parameter minFractionDigits: minimum number of digits in a fraction
	/// - Parameter maxFractionDigits: maximum number of digits in a fraction
	/// - Returns: Formatted string
	func triadString(_ string: String, minFractionDigits: Int, maxFractionDigits: Int) -> String {
		triadNumberFormatter.minimumFractionDigits = minFractionDigits
		triadNumberFormatter.maximumFractionDigits = maxFractionDigits
		return triadNumberFormatter.string(from: NSNumber(value: string.toDouble())) ?? Extendy.defaultValue
	}

	/// Devide the string with white spaces every 4 symbols (credit card format)
	/// - Parameter string: String for formatting
	func creditCardString(_ string: String) -> String {
		string.separate()
	}

	/// Devide the string with white spaces every 4 symbols (IBAN format)
	/// - Parameter string: String for formatting
	func ibanString(_ string: String) -> String {
		string.separate()
	}

	/// Format string with own `NumberFormatter`
	/// - Parameters:
	///   - string: String for formatting
	///   - formatter: Custom `NumberFormatter`
	func formatString(_ string: String, with formatter: NumberFormatter) -> String {
		formatter.string(from: NSNumber(value: string.toDouble())) ?? "0\(formatter.decimalSeparator ?? ",")00"
	}
}
