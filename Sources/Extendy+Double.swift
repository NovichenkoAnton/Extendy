//
//  Extendy+Double.swift
//  Extendy
//
//  Created by Anton Novichenko on 20.05.21.
//  Copyright © 2021 Anton Novichenko. All rights reserved.
//

import Foundation

extension Double {
	public func round(_ precision: Int) -> Double {
		let multiplier = pow(10, Double(precision))
		return Darwin.round(self * multiplier) / multiplier
	}
}
