//
//  SettingsManager.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.07.2024.
//

import Foundation
import Combine
import HealthKit
import Observation

@Observable
final class SettingsManager {
    
    static let shared = SettingsManager()

    @ObservationIgnored private let defaults = UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")
    
    private(set) var unitOfMeasure: UnitOfMeasure {
        didSet {
            defaults?.set(unitOfMeasure.rawValue, forKey: "UNIT_OF_MEASURE")
            notifyObservers()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let subject = PassthroughSubject<Void, Never>()
    
    private init() {
        
        let savedUnitOfMeasure = defaults?.string(forKey: "UNIT_OF_MEASURE") ?? UnitOfMeasure.metric.rawValue

        self.unitOfMeasure = UnitOfMeasure(rawValue: savedUnitOfMeasure) ?? .metric
    }
    
    func addObserver(_ observer: @escaping () -> Void) {
        subject.sink(receiveValue: observer).store(in: &cancellables)
    }
    
    private func notifyObservers() {
        subject.send(())
    }
    
    func setUnitOfMeasure(to unit: UnitOfMeasure) {
        if self.unitOfMeasure != unit {
            self.unitOfMeasure = unit
        }
    }
}
