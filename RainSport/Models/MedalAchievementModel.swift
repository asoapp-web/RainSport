import Foundation

struct MedalAchievementModel: Identifiable {
    let id: UUID
    let titleText: String
    let descriptionText: String
    let iconSystemName: String
    let targetValue: Int
    var currentProgress: Int
    var isUnlocked: Bool
    
    var progressPercentage: Double {
        return min(Double(currentProgress) / Double(targetValue), 1.0) * 100.0
    }
    
    init(id: UUID = UUID(),
         titleText: String,
         descriptionText: String,
         iconSystemName: String,
         targetValue: Int,
         currentProgress: Int = 0,
         isUnlocked: Bool = false) {
        self.id = id
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.iconSystemName = iconSystemName
        self.targetValue = targetValue
        self.currentProgress = currentProgress
        self.isUnlocked = isUnlocked
    }
}


