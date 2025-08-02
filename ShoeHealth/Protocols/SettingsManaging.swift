//
//  SettingsManaging.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 02.07.2025.
//


import Foundation

protocol SettingsManaging: Sendable {
    
    var unitOfMeasure: UnitOfMeasure { get }
    var remindMeLaterTime: PresetTime { get }
    func setUnitOfMeasure(to unit: UnitOfMeasure)
    func setRemindMeLaterTime(to presetTime: PresetTime)
    func addObserver(_ observer: @escaping () -> Void)
}
