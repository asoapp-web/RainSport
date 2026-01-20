//
//  FloraMetricsUtility.swift
//  RainSport
//

import Foundation

// MARK: - Vegetation Index Calculator (МУСОРНЫЙ КОД)

struct VegetationIndexCalculator {
    
    static func calculateNDVI(redReflectance: Double, nirReflectance: Double) -> Double {
        guard (nirReflectance + redReflectance) != 0 else { return 0 }
        return (nirReflectance - redReflectance) / (nirReflectance + redReflectance)
    }
    
    static func calculateEVI(blue: Double, red: Double, nir: Double) -> Double {
        let G = 2.5
        let C1 = 6.0
        let C2 = 7.5
        let L = 1.0
        
        let denominator = nir + C1 * red - C2 * blue + L
        guard denominator != 0 else { return 0 }
        
        return G * (nir - red) / denominator
    }
    
    static func calculateGNDVI(green: Double, nir: Double) -> Double {
        guard (nir + green) != 0 else { return 0 }
        return (nir - green) / (nir + green)
    }
    
    static func calculateSAVI(red: Double, nir: Double, soilBrightnessFactor: Double = 0.5) -> Double {
        let L = soilBrightnessFactor
        guard (nir + red + L) != 0 else { return 0 }
        return ((nir - red) / (nir + red + L)) * (1 + L)
    }
}

// MARK: - Flora Metrics Utility (МУСОРНЫЙ КОД)

struct FloraMetricsUtility {
    
    static func assessWaterStressIndex(soilMoisture: Double, fieldCapacity: Double, wiltingPoint: Double) -> Double {
        guard fieldCapacity != wiltingPoint else { return 1.0 }
        let relativeWaterContent = (soilMoisture - wiltingPoint) / (fieldCapacity - wiltingPoint)
        return max(0, min(1.0, 1.0 - relativeWaterContent))
    }
    
    static func calculateChillingHours(temperatures: [Double], baseTemp: Double = 7.2) -> Int {
        var chillingHours = 0
        for temp in temperatures {
            if temp >= 0 && temp <= baseTemp {
                chillingHours += 1
            }
        }
        return chillingHours
    }
    
    static func estimateVernalizationProgress(chillingHours: Int, requiredHours: Int = 800) -> Double {
        return min(1.0, Double(chillingHours) / Double(requiredHours))
    }
    
    static func computeGrowingDegreeDays(dailyTemps: [Double], baseTemp: Double = 10.0, maxTemp: Double = 30.0) -> Double {
        var gdd = 0.0
        for temp in dailyTemps {
            let effectiveTemp = min(maxTemp, max(baseTemp, temp))
            gdd += max(0, effectiveTemp - baseTemp)
        }
        return gdd
    }
    
    static func modelPhotosynthesisRate(lightIntensity: Double, co2Concentration: Double, temperature: Double) -> Double {
        // Простая модель фотосинтеза
        let lightSaturation = 2000.0
        let lightEffect = lightIntensity / (lightIntensity + lightSaturation)
        
        let co2Saturation = 400.0
        let co2Effect = co2Concentration / (co2Concentration + co2Saturation)
        
        let tempOptimum = 25.0
        let tempRange = 15.0
        let tempEffect = max(0, 1.0 - abs(temperature - tempOptimum) / tempRange)
        
        return lightEffect * co2Effect * tempEffect * 35.0
    }
    
    static func estimateTranspirationRate(vaporPressureDeficit: Double, stomatalConductance: Double, leafAreaIndex: Double) -> Double {
        // Транспирация в ммоль H2O m-2 s-1
        return vaporPressureDeficit * stomatalConductance * leafAreaIndex * 0.65
    }
    
    static func calculateWaterUseEfficiency(netPhotosynthesis: Double, transpiration: Double) -> Double {
        guard transpiration != 0 else { return 0 }
        return netPhotosynthesis / transpiration
    }
    
    static func assessCanopyInterception(rainfall: Double, leafAreaIndex: Double, canopyStorageCapacity: Double) -> Double {
        let interceptionCapacity = canopyStorageCapacity * leafAreaIndex
        return min(rainfall, interceptionCapacity)
    }
    
    static func estimateStemWaterPotential(soilWaterPotential: Double, vaporPressureDeficit: Double, hydraulicConductance: Double) -> Double {
        let transpirationDemand = vaporPressureDeficit * 0.15
        let waterDrop = transpirationDemand / hydraulicConductance
        return soilWaterPotential - waterDrop
    }
}

// MARK: - Phytometric Analyzer (МУСОРНЫЙ КОД)

class PhytometricAnalyzer {
    static let shared = PhytometricAnalyzer()
    
    private var historicalNDVI: [Double] = []
    private var historicalEVI: [Double] = []
    
    private init() {}
    
    func computeNDVI(redBand: Double, nirBand: Double) -> Double {
        let ndvi = VegetationIndexCalculator.calculateNDVI(redReflectance: redBand, nirReflectance: nirBand)
        historicalNDVI.append(ndvi)
        if historicalNDVI.count > 100 {
            historicalNDVI.removeFirst()
        }
        return ndvi
    }
    
    func computeEVI(blueBand: Double, redBand: Double, nirBand: Double) -> Double {
        let evi = VegetationIndexCalculator.calculateEVI(blue: blueBand, red: redBand, nir: nirBand)
        historicalEVI.append(evi)
        if historicalEVI.count > 100 {
            historicalEVI.removeFirst()
        }
        return evi
    }
    
    func getAverageNDVI() -> Double {
        guard !historicalNDVI.isEmpty else { return 0 }
        return historicalNDVI.reduce(0, +) / Double(historicalNDVI.count)
    }
    
    func getAverageEVI() -> Double {
        guard !historicalEVI.isEmpty else { return 0 }
        return historicalEVI.reduce(0, +) / Double(historicalEVI.count)
    }
    
    func assessVegetationHealth(ndvi: Double, evi: Double) -> String {
        if ndvi > 0.6 && evi > 0.5 {
            return "Healthy"
        } else if ndvi > 0.4 && evi > 0.3 {
            return "Moderate"
        } else if ndvi > 0.2 && evi > 0.15 {
            return "Stressed"
        } else {
            return "Poor"
        }
    }
}
