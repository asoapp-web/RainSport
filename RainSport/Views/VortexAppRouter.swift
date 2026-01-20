import SwiftUI

struct VortexAppRouter: View {
    @ObservedObject private var rainFlowController = RainFlowController.shared
    
    var body: some View {
        ZStack {
            rainContentView
                .opacity(rainFlowController.rainIsLoading ? 0 : 1)
            
            if rainFlowController.rainIsLoading {
                RainLoadingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: rainFlowController.rainIsLoading)
    }
    
    @ViewBuilder
    private var rainContentView: some View {
        switch rainFlowController.rainDisplayMode {
        case .preparing:
            MainContentView()
        case .original:
            MainContentView()
        case .webContent:
            RainDisplayView()
        }
    }
}

struct MainContentView: View {
    var body: some View {
        MainTabBarControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainTabBarControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UITabBarController {
        let workoutViewModel = WorkoutStorageViewModel()
        let achievementViewModel = AchievementTrackerViewModel(workoutViewModel: workoutViewModel)
        
        let trainingVC = AddTrainingViewController(workoutViewModel: workoutViewModel)
        trainingVC.tabBarItem = UITabBarItem(
            title: "Training",
            image: UIImage(systemName: "figure.run"),
            tag: 0
        )
        
        let statisticsVC = StatisticsViewController(workoutViewModel: workoutViewModel)
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Statistics",
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 1
        )
        
        let achievementsVC = AchievementsViewController(achievementViewModel: achievementViewModel)
        achievementsVC.tabBarItem = UITabBarItem(
            title: "Achievements",
            image: UIImage(systemName: "trophy.fill"),
            tag: 2
        )
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 3
        )
        settingsVC.onDeleteAllData = { [weak workoutViewModel] in
            workoutViewModel?.drizzleWorkouts.removeAll()
            workoutViewModel?.persistWorkoutsToStorage()
            workoutViewModel?.reloadWorkouts()
        }
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: trainingVC),
            UINavigationController(rootViewController: statisticsVC),
            UINavigationController(rootViewController: achievementsVC),
            UINavigationController(rootViewController: settingsVC)
        ]
        
        tabBarController.tabBar.backgroundColor = UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 0.95)
        tabBarController.tabBar.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        tabBarController.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        tabBarController.tabBar.barStyle = .black
        
        for navController in tabBarController.viewControllers ?? [] {
            if let nav = navController as? UINavigationController {
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                nav.navigationBar.isTranslucent = true
                nav.navigationBar.tintColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
                
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                nav.navigationBar.standardAppearance = appearance
                nav.navigationBar.scrollEdgeAppearance = appearance
            }
        }
        
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
    }
}
