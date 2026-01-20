import UIKit
import Combine

class StatisticsViewController: UIViewController {
    
    private var workoutViewModel: WorkoutStorageViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollContainerView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let rainAnimationLayer = CAEmitterLayer()
    
    init(workoutViewModel: WorkoutStorageViewModel) {
        self.workoutViewModel = workoutViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        setupGradientBackground()
        setupRainAnimation()
        setupViews()
        setupConstraints()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStatistics()
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
        rainAnimationLayer.frame = view.bounds
        rainAnimationLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        rainAnimationLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
    }
    
    private func setupRainAnimation() {
        rainAnimationLayer.frame = view.bounds
        rainAnimationLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        rainAnimationLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        rainAnimationLayer.emitterShape = .line
        
        let dropletCell = CAEmitterCell()
        dropletCell.contents = createDropletImage().cgImage
        dropletCell.birthRate = 15
        dropletCell.lifetime = 8.0
        dropletCell.velocity = 200
        dropletCell.velocityRange = 50
        dropletCell.yAcceleration = 100
        dropletCell.scale = 0.5
        dropletCell.scaleRange = 0.3
        dropletCell.alphaSpeed = -0.1
        dropletCell.alphaRange = 0.5
        
        rainAnimationLayer.emitterCells = [dropletCell]
        view.layer.insertSublayer(rainAnimationLayer, at: 1)
    }
    
    private func createDropletImage() -> UIImage {
        let size = CGSize(width: 10, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: 0))
            path.addQuadCurve(to: CGPoint(x: size.width / 2, y: size.height), 
                            controlPoint: CGPoint(x: 0, y: size.height * 0.6))
            path.addQuadCurve(to: CGPoint(x: size.width / 2, y: 0), 
                            controlPoint: CGPoint(x: size.width, y: size.height * 0.6))
            path.close()
            
            UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.6).setFill()
            path.fill()
        }
    }
    
    private func setupViews() {
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.showsVerticalScrollIndicator = true
        view.addSubview(scrollContainerView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.distribution = .fill
        scrollContainerView.addSubview(contentStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupObservers() {
        workoutViewModel.$drizzleWorkouts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshStatistics()
            }
            .store(in: &cancellables)
    }
    
    private func refreshStatistics() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let overviewCard = createOverviewCard()
        contentStackView.addArrangedSubview(overviewCard)
        
        let weatherDistributionCard = createWeatherDistributionCard()
        contentStackView.addArrangedSubview(weatherDistributionCard)
        
        let chartCard = createChartCard()
        contentStackView.addArrangedSubview(chartCard)
        
        let recentActivityCard = createRecentActivityCard()
        contentStackView.addArrangedSubview(recentActivityCard)
    }
    
    private func createOverviewCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Overview"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let totalCount = workoutViewModel.getTotalWorkoutCount()
        let totalMinutes = workoutViewModel.getTotalDurationMinutes()
        let avgTemp = workoutViewModel.getAverageTemperature()
        
        let statsStack = UIStackView()
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 12
        container.addSubview(statsStack)
        
        let stat1 = createStatBox(title: "Total", value: "\(totalCount)", subtitle: "sessions")
        let stat2 = createStatBox(title: "Time", value: "\(totalMinutes)", subtitle: "minutes")
        let stat3 = createStatBox(title: "Avg Temp", value: String(format: "%.1f", avgTemp), subtitle: "°C")
        
        statsStack.addArrangedSubview(stat1)
        statsStack.addArrangedSubview(stat2)
        statsStack.addArrangedSubview(stat3)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            statsStack.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return container
    }
    
    private func createStatBox(title: String, value: String, subtitle: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
        ])
        
        return container
    }
    
    private func createWeatherDistributionCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Weather Distribution"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        container.addSubview(stackView)
        
        for weatherType in WeatherConditionType.allCases {
            let count = workoutViewModel.getWeatherConditionCount(weatherType)
            let row = createWeatherRow(weather: weatherType, count: count)
            stackView.addArrangedSubview(row)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createWeatherRow(weather: WeatherConditionType, count: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = weather.rawValue
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.textColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        countLabel.font = .systemFont(ofSize: 15, weight: .bold)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(countLabel)
        
        let barBackground = UIView()
        barBackground.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        barBackground.layer.cornerRadius = 4
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(barBackground)
        
        let barForeground = UIView()
        barForeground.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        barForeground.layer.cornerRadius = 4
        barForeground.translatesAutoresizingMaskIntoConstraints = false
        barBackground.addSubview(barForeground)
        
        let maxCount = workoutViewModel.getTotalWorkoutCount()
        let percentage = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 80),
            
            barBackground.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            barBackground.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -8),
            barBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            barBackground.heightAnchor.constraint(equalToConstant: 20),
            
            barForeground.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
            barForeground.topAnchor.constraint(equalTo: barBackground.topAnchor),
            barForeground.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
            barForeground.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: max(percentage, 0.05)),
            
            countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        return container
    }
    
    private func createChartCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Last 7 Days Activity"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let chartView = createSimpleBarChart()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return container
    }
    
    private func createSimpleBarChart() -> UIView {
        let chartContainer = UIView()
        chartContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        chartContainer.layer.cornerRadius = 12
        
        let calendar = Calendar.current
        var dailyCounts: [Int] = []
        
        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let count = workoutViewModel.drizzleWorkouts.filter { workout in
                workout.timestamp >= startOfDay && workout.timestamp < endOfDay
            }.count
            
            dailyCounts.append(count)
        }
        
        let maxCount = dailyCounts.max() ?? 1
        let barWidth: CGFloat = 35
        let barSpacing: CGFloat = 10
        
        let barsStackView = UIStackView()
        barsStackView.translatesAutoresizingMaskIntoConstraints = false
        barsStackView.axis = .horizontal
        barsStackView.distribution = .fillEqually
        barsStackView.spacing = barSpacing
        chartContainer.addSubview(barsStackView)
        
        for (index, count) in dailyCounts.enumerated() {
            let barContainer = UIView()
            
            let barView = UIView()
            barView.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
            barView.layer.cornerRadius = 4
            barView.translatesAutoresizingMaskIntoConstraints = false
            barContainer.addSubview(barView)
            
            let countLabel = UILabel()
            countLabel.text = "\(count)"
            countLabel.textColor = .white
            countLabel.font = .systemFont(ofSize: 12, weight: .bold)
            countLabel.textAlignment = .center
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            barContainer.addSubview(countLabel)
            
            let dayLabel = UILabel()
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            dayLabel.text = formatter.string(from: date).prefix(1).uppercased()
            dayLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            dayLabel.font = .systemFont(ofSize: 11)
            dayLabel.textAlignment = .center
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            barContainer.addSubview(dayLabel)
            
            let barHeightPercentage = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0
            let minBarHeight: CGFloat = 20
            let maxBarHeight: CGFloat = 120
            let barHeight = minBarHeight + (maxBarHeight - minBarHeight) * barHeightPercentage
            
            NSLayoutConstraint.activate([
                barView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor, constant: -25),
                barView.centerXAnchor.constraint(equalTo: barContainer.centerXAnchor),
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: barHeight),
                
                countLabel.bottomAnchor.constraint(equalTo: barView.topAnchor, constant: -4),
                countLabel.centerXAnchor.constraint(equalTo: barContainer.centerXAnchor),
                
                dayLabel.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 4),
                dayLabel.centerXAnchor.constraint(equalTo: barContainer.centerXAnchor)
            ])
            
            barsStackView.addArrangedSubview(barContainer)
        }
        
        NSLayoutConstraint.activate([
            barsStackView.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: 12),
            barsStackView.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor, constant: -12),
            barsStackView.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 12),
            barsStackView.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -12)
        ])
        
        return chartContainer
    }
    
    private func createRecentActivityCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Recent Activity"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let last7Days = workoutViewModel.getWorkoutsForLastDays(7)
        
        let activityLabel = UILabel()
        activityLabel.text = "Workouts in last 7 days: \(last7Days.count)"
        activityLabel.textColor = .white
        activityLabel.font = .systemFont(ofSize: 15)
        activityLabel.numberOfLines = 0
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(activityLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            activityLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            activityLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            activityLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            activityLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
}

