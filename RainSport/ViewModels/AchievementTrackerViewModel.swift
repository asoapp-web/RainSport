import Foundation
import Combine

class AchievementTrackerViewModel: ObservableObject {
    @Published var medalAchievements: [MedalAchievementModel] = []
    
    private var workoutViewModel: WorkoutStorageViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutViewModel: WorkoutStorageViewModel) {
        self.workoutViewModel = workoutViewModel
        initializeAchievementsList()
        refreshAchievementProgress()
        observeWorkoutChanges()
    }
    
    private func initializeAchievementsList() {
        medalAchievements = [
            MedalAchievementModel(
                titleText: "First Droplet",
                descriptionText: "Complete your first training session",
                iconSystemName: "drop.fill",
                targetValue: 1
            ),
            MedalAchievementModel(
                titleText: "Rain Warrior",
                descriptionText: "Train 5 times in rainy conditions",
                iconSystemName: "cloud.rain.fill",
                targetValue: 5
            ),
            MedalAchievementModel(
                titleText: "Storm Chaser",
                descriptionText: "Complete 10 total training sessions",
                iconSystemName: "cloud.bolt.fill",
                targetValue: 10
            ),
            MedalAchievementModel(
                titleText: "Snow Explorer",
                descriptionText: "Train 3 times in snowy weather",
                iconSystemName: "snowflake",
                targetValue: 3
            ),
            MedalAchievementModel(
                titleText: "Dedication Master",
                descriptionText: "Reach 25 total training sessions",
                iconSystemName: "star.fill",
                targetValue: 25
            ),
            MedalAchievementModel(
                titleText: "Weather Veteran",
                descriptionText: "Train in all 7 weather conditions",
                iconSystemName: "sparkles",
                targetValue: 7
            ),
            MedalAchievementModel(
                titleText: "Marathon Spirit",
                descriptionText: "Accumulate 600 minutes of training",
                iconSystemName: "timer",
                targetValue: 600
            ),
            MedalAchievementModel(
                titleText: "Century Club",
                descriptionText: "Complete 100 training sessions",
                iconSystemName: "crown.fill",
                targetValue: 100
            )
        ]
    }
    
    private func observeWorkoutChanges() {
        workoutViewModel.$drizzleWorkouts
            .sink { [weak self] _ in
                self?.refreshAchievementProgress()
            }
            .store(in: &cancellables)
    }
    
    private func refreshAchievementProgress() {
        let totalWorkouts = workoutViewModel.getTotalWorkoutCount()
        let rainyCount = workoutViewModel.getWeatherConditionCount(.rainy)
        let snowyCount = workoutViewModel.getWeatherConditionCount(.snowy)
        let totalMinutes = workoutViewModel.getTotalDurationMinutes()
        let uniqueWeatherCount = Set(workoutViewModel.drizzleWorkouts.map { $0.weatherCondition }).count
        
        for index in medalAchievements.indices {
            switch medalAchievements[index].titleText {
            case "First Droplet":
                medalAchievements[index].currentProgress = totalWorkouts
                medalAchievements[index].isUnlocked = totalWorkouts >= 1
            case "Rain Warrior":
                medalAchievements[index].currentProgress = rainyCount
                medalAchievements[index].isUnlocked = rainyCount >= 5
            case "Storm Chaser":
                medalAchievements[index].currentProgress = totalWorkouts
                medalAchievements[index].isUnlocked = totalWorkouts >= 10
            case "Snow Explorer":
                medalAchievements[index].currentProgress = snowyCount
                medalAchievements[index].isUnlocked = snowyCount >= 3
            case "Dedication Master":
                medalAchievements[index].currentProgress = totalWorkouts
                medalAchievements[index].isUnlocked = totalWorkouts >= 25
            case "Weather Veteran":
                medalAchievements[index].currentProgress = uniqueWeatherCount
                medalAchievements[index].isUnlocked = uniqueWeatherCount >= 7
            case "Marathon Spirit":
                medalAchievements[index].currentProgress = totalMinutes
                medalAchievements[index].isUnlocked = totalMinutes >= 600
            case "Century Club":
                medalAchievements[index].currentProgress = totalWorkouts
                medalAchievements[index].isUnlocked = totalWorkouts >= 100
            default:
                break
            }
        }
        
        objectWillChange.send()
    }
}

