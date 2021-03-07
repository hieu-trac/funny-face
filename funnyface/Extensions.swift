//
//  Extensions.swift
//  funnyface
//
//  Created by Hieu C Trac on 3/7/21.
//

import Foundation

typealias Degrees = Float
typealias Radians = Float

extension Degrees {
    var radians: Radians { return self * .pi / 180  }
}
