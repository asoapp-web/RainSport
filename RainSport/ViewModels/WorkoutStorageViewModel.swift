import Foundation
import Combine

class WorkoutStorageViewModel: ObservableObject {
    @Published var drizzleWorkouts: [DrizzleWorkoutModel] = []
    
    private let storageKeyPath = "savedDrizzleWorkouts"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPersistentWorkouts()
    }
    
    func appendNewWorkout(_ workout: DrizzleWorkoutModel) {
        drizzleWorkouts.insert(workout, at: 0)
        persistWorkoutsToStorage()
    }
    
    func removeWorkoutById(_ id: UUID) {
        drizzleWorkouts.removeAll { $0.id == id }
        persistWorkoutsToStorage()
    }
    
    func getTotalWorkoutCount() -> Int {
        return drizzleWorkouts.count
    }
    
    func getWeatherConditionCount(_ condition: WeatherConditionType) -> Int {
        return drizzleWorkouts.filter { $0.weatherCondition == condition }.count
    }
    
    func getTotalDurationMinutes() -> Int {
        return drizzleWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }
    
    func getAverageTemperature() -> Double {
        guard !drizzleWorkouts.isEmpty else { return 0 }
        let sum = drizzleWorkouts.reduce(0.0) { $0 + $1.temperatureCelsius }
        return sum / Double(drizzleWorkouts.count)
    }
    
    func getWorkoutsForLastDays(_ days: Int) -> [DrizzleWorkoutModel] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return drizzleWorkouts.filter { $0.timestamp >= startDate }
    }
    
    func persistWorkoutsToStorage() {
        if let encodedData = try? JSONEncoder().encode(drizzleWorkouts) {
            UserDefaults.standard.set(encodedData, forKey: storageKeyPath)
        }
    }
    
    private func loadPersistentWorkouts() {
        if let savedData = UserDefaults.standard.data(forKey: storageKeyPath),
           let decodedWorkouts = try? JSONDecoder().decode([DrizzleWorkoutModel].self, from: savedData) {
            drizzleWorkouts = decodedWorkouts
        } else {
            drizzleWorkouts = []
        }
    }
    
    func reloadWorkouts() {
        loadPersistentWorkouts()
    }
}

