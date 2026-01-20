import UIKit
import Combine

class AchievementsViewController: UIViewController {
    
    private var achievementViewModel: AchievementTrackerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollContainerView = UIScrollView()
    private let achievementsStackView = UIStackView()
    
    private var previousUnlockedIds = Set<UUID>()
    
    init(achievementViewModel: AchievementTrackerViewModel) {
        self.achievementViewModel = achievementViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Achievements"
        setupGradientBackground()
        setupViews()
        setupConstraints()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAchievements()
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
    }
    
    private func setupViews() {
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.showsVerticalScrollIndicator = true
        view.addSubview(scrollContainerView)
        
        achievementsStackView.translatesAutoresizingMaskIntoConstraints = false
        achievementsStackView.axis = .vertical
        achievementsStackView.spacing = 16
        achievementsStackView.distribution = .fill
        scrollContainerView.addSubview(achievementsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            achievementsStackView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 16),
            achievementsStackView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            achievementsStackView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            achievementsStackView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor, constant: -16),
            achievementsStackView.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupObservers() {
        achievementViewModel.$medalAchievements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshAchievements()
            }
            .store(in: &cancellables)
    }
    
    private func refreshAchievements() {
        achievementsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let unlockedCount = achievementViewModel.medalAchievements.filter { $0.isUnlocked }.count
        let totalCount = achievementViewModel.medalAchievements.count
        
        let headerCard = createHeaderCard(unlocked: unlockedCount, total: totalCount)
        achievementsStackView.addArrangedSubview(headerCard)
        
        let currentUnlockedIds = Set(achievementViewModel.medalAchievements.filter { $0.isUnlocked }.map { $0.id })
        let newlyUnlockedIds = currentUnlockedIds.subtracting(previousUnlockedIds)
        
        for achievement in achievementViewModel.medalAchievements {
            let card = createAchievementCard(achievement: achievement)
            achievementsStackView.addArrangedSubview(card)
            
            if newlyUnlockedIds.contains(achievement.id) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.showConfettiOnCard(card)
                }
            }
        }
        
        previousUnlockedIds = currentUnlockedIds
    }
    
    private func createHeaderCard(unlocked: Int, total: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 0.5)
        container.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Your Progress"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let progressLabel = UILabel()
        progressLabel.text = "\(unlocked) / \(total) Achievements Unlocked"
        progressLabel.textColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        progressLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressLabel)
        
        let percentageLabel = UILabel()
        let percentage = total > 0 ? Int(Double(unlocked) / Double(total) * 100) : 0
        percentageLabel.text = "\(percentage)%"
        percentageLabel.textColor = .white
        percentageLabel.font = .systemFont(ofSize: 36, weight: .bold)
        percentageLabel.textAlignment = .center
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(percentageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            percentageLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            percentageLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            progressLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            
            container.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        return container
    }
    
    private func createAchievementCard(achievement: MedalAchievementModel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = achievement.isUnlocked ? 
            UIColor(red: 0.15, green: 0.35, blue: 0.6, alpha: 0.4) :
            UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        container.layer.borderWidth = achievement.isUnlocked ? 2 : 0
        container.layer.borderColor = achievement.isUnlocked ? 
            UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0).cgColor : nil
        
        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = achievement.isUnlocked ?
            UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.3) :
            UIColor(white: 1.0, alpha: 0.05)
        iconBackgroundView.layer.cornerRadius = 30
        container.addSubview(iconBackgroundView)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: achievement.iconSystemName)
        iconImageView.tintColor = achievement.isUnlocked ? 
            UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0) : 
            UIColor.white.withAlphaComponent(0.3)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = achievement.titleText
        titleLabel.textColor = achievement.isUnlocked ? .white : UIColor.white.withAlphaComponent(0.5)
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = achievement.descriptionText
        descriptionLabel.textColor = achievement.isUnlocked ? 
            UIColor.white.withAlphaComponent(0.8) : 
            UIColor.white.withAlphaComponent(0.4)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descriptionLabel)
        
        let progressContainerView = UIView()
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressContainerView)
        
        let progressBackgroundView = UIView()
        progressBackgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        progressBackgroundView.layer.cornerRadius = 6
        progressBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressBackgroundView)
        
        let progressForegroundView = UIView()
        progressForegroundView.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
        progressForegroundView.layer.cornerRadius = 6
        progressForegroundView.translatesAutoresizingMaskIntoConstraints = false
        progressBackgroundView.addSubview(progressForegroundView)
        
        let progressLabel = UILabel()
        progressLabel.text = "\(achievement.currentProgress) / \(achievement.targetValue)"
        progressLabel.textColor = .white
        progressLabel.font = .systemFont(ofSize: 12, weight: .medium)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressLabel)
        
        let progressPercentage = min(CGFloat(achievement.currentProgress) / CGFloat(achievement.targetValue), 1.0)
        
        NSLayoutConstraint.activate([
            iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 60),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 60),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            progressContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            progressContainerView.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            progressContainerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            progressContainerView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            progressBackgroundView.topAnchor.constraint(equalTo: progressContainerView.topAnchor),
            progressBackgroundView.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor),
            progressBackgroundView.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor),
            progressBackgroundView.heightAnchor.constraint(equalToConstant: 12),
            
            progressForegroundView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor),
            progressForegroundView.leadingAnchor.constraint(equalTo: progressBackgroundView.leadingAnchor),
            progressForegroundView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor),
            progressForegroundView.widthAnchor.constraint(equalTo: progressBackgroundView.widthAnchor, multiplier: max(progressPercentage, 0.05)),
            
            progressLabel.topAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor, constant: 4),
            progressLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        return container
    }
    
    private func showConfettiOnCard(_ card: UIView) {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.frame = card.bounds
        confettiLayer.emitterPosition = CGPoint(x: card.bounds.width / 2, y: -10)
        confettiLayer.emitterSize = CGSize(width: card.bounds.width, height: 1)
        confettiLayer.emitterShape = .line
        confettiLayer.beginTime = CACurrentMediaTime()
        confettiLayer.birthRate = 1.0
        
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0),
            UIColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0)
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = createConfettiShape(color: color).cgImage
            cell.birthRate = 15
            cell.lifetime = 3.0
            cell.velocity = 150
            cell.velocityRange = 80
            cell.emissionRange = .pi * 0.3
            cell.spin = 4
            cell.spinRange = 8
            cell.scale = 0.3
            cell.scaleRange = 0.2
            cell.yAcceleration = 200
            cell.alphaSpeed = -0.4
            cells.append(cell)
        }
        
        confettiLayer.emitterCells = cells
        card.layer.addSublayer(confettiLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiLayer.birthRate = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    
    private func createConfettiShape(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            
            let shapeType = Int.random(in: 0...2)
            
            switch shapeType {
            case 0:
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                context.cgContext.fillEllipse(in: rect)
            case 1:
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                context.cgContext.fill(rect)
            default:
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.close()
                path.fill()
            }
        }
    }
}

