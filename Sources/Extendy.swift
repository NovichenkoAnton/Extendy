//
//  Extendy.swift
//  Extendy
//
//  Created by Anton Novichenko on 3/12/20.
//  Copyright © 2020 Anton Novichenko. All rights reserved.
//

import Foundation

public protocol ExtendyCompatible {
	associatedtype CompatibleType

	static var ext: Extendy<CompatibleType>.Type { get set }
	var ext: Extendy<CompatibleType> { get set }
}

public class Extendy<Base> {
	let ext: Base

	init(_ ext: Base) {
		self.ext = ext
	}

	lazy var triadNumberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.decimalSeparator = ","
		formatter.groupingSeparator = " "
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		return formatter
	}()

	lazy var cleanNumberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.decimalSeparator = "."
		formatter.groupingSeparator = ""
		return formatter
	}()

	lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = Calendar(identifier: .iso8601)
		dateFormatter.timeZone = TimeZone.current
		return dateFormatter
	}()
}

public extension ExtendyCompatible {
	static var ext: Extendy<Self>.Type {
		get { Extendy<Self>.self }
		set {}
	}

	var ext: Extendy<Self> {
		get { Extendy(self) }
		set {}
	}
}
