//
//  DeliveredInsulin.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 3/27/18.
//

import Foundation

public class DeliveredInsulin: Codable {
    public var bolusAmountDelivered: Float!
    public var basalAmountDelivered: Float!
    
    public init(bolusAmountDelivered: Float!, basalAmountDelivered: Float!) {
        self.bolusAmountDelivered = bolusAmountDelivered
        self.basalAmountDelivered = basalAmountDelivered
    }
}

