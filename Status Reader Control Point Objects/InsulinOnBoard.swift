//
//  InsulinOnBoard.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 3/27/18.
//

import Foundation

public class InsulinOnBoard: Codable {
    public var flags: UInt8
    public var insulinOnBoard: Float
    public var remainingDuration: UInt16?
    
    public init(flags: UInt8, insulinOnBoard: Float, remainingDuration: UInt16?) {
        self.flags = flags
        self.insulinOnBoard = insulinOnBoard
        self.remainingDuration = remainingDuration
    }
}

