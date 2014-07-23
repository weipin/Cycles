//
//  Error.swift
//  CyclesTouch
//
//  Created by Weipin Xia on 6/17/14.
//  Copyright (c) 2014 Cocoahope. All rights reserved.
//

import Foundation

public let CycleErrorDomain = "CycleError"

public enum CycleErrorCode: Int {
    case ObjectKindNotMatch = 1
    case StatusCodeSeemsToHaveErred
    case PreparationFailure
}