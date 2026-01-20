import Foundation

struct DrizzleWorkoutModel: Codable, Identifiable {
    let id: UUID
    var activityName: String
    var durationMinutes: Int
    var weatherCondition: WeatherConditionType
    var temperatureCelsius: Double
    var intensityLevel: Int
    var notes: String
    var timestamp: Date
    
    init(id: UUID = UUID(),
         activityName: String,
         durationMinutes: Int,
         weatherCondition: WeatherConditionType,
         temperatureCelsius: Double,
         intensityLevel: Int,
         notes: String = "",
         timestamp: Date = Date()) {
        self.id = id
        self.activityName = activityName
        self.durationMinutes = durationMinutes
        self.weatherCondition = weatherCondition
        self.temperatureCelsius = temperatureCelsius
        self.intensityLevel = intensityLevel
        self.notes = notes
        self.timestamp = timestamp
    }
}

enum WeatherConditionType: String, Codable, CaseIterable {
    case rainy = "Rain"
    case snowy = "Snow"
    case cloudy = "Cloudy"
    case sunny = "Sunny"
    case foggy = "Foggy"
    case windy = "Windy"
    case stormy = "Stormy"
    
    var iconName: String {
        switch self {
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "snow"
        case .cloudy: return "cloud.fill"
        case .sunny: return "sun.max.fill"
        case .foggy: return "cloud.fog.fill"
        case .windy: return "wind"
        case .stormy: return "cloud.bolt.rain.fill"
        }
    }
}


