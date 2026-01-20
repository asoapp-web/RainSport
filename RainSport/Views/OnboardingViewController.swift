import UIKit

class OnboardingViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let continueButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    
    private var currentPageIndex = 0
    
    private let onboardingPages = [
        OnboardingPageData(
            iconSystemName: "cloud.rain.fill",
            titleText: "Track Your Training",
            descriptionText: "Record every workout session with detailed weather conditions and performance metrics",
            backgroundColor: UIColor(red: 0.1, green: 0.25, blue: 0.45, alpha: 1.0)
        ),
        OnboardingPageData(
            iconSystemName: "chart.bar.fill",
            titleText: "Analyze Statistics",
            descriptionText: "View comprehensive charts and insights about your training progress over time",
            backgroundColor: UIColor(red: 0.08, green: 0.18, blue: 0.35, alpha: 1.0)
        ),
        OnboardingPageData(
            iconSystemName: "trophy.fill",
            titleText: "Unlock Achievements",
            descriptionText: "Complete challenges and earn medals as you reach new milestones in your journey",
            backgroundColor: UIColor(red: 0.06, green: 0.12, blue: 0.25, alpha: 1.0)
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        createOnboardingPages()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = onboardingPages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        continueButton.layer.cornerRadius = 14
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -30),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func createOnboardingPages() {
        let width = view.bounds.width
        let height = scrollView.bounds.height
        
        scrollView.contentSize = CGSize(width: width * CGFloat(onboardingPages.count), height: height)
        
        for (index, pageData) in onboardingPages.enumerated() {
            let pageView = createPageView(with: pageData, at: index)
            scrollView.addSubview(pageView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let width = view.bounds.width
        scrollView.contentSize = CGSize(width: width * CGFloat(onboardingPages.count), height: scrollView.bounds.height)
        
        for (index, pageData) in onboardingPages.enumerated() {
            let pageView = createPageView(with: pageData, at: index)
            scrollView.addSubview(pageView)
        }
    }
    
    private func createPageView(with data: OnboardingPageData, at index: Int) -> UIView {
        let pageView = UIView()
        let xPosition = view.bounds.width * CGFloat(index)
        pageView.frame = CGRect(x: xPosition, y: 0, width: view.bounds.width, height: scrollView.bounds.height)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            data.backgroundColor.cgColor,
            data.backgroundColor.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = pageView.bounds
        pageView.layer.insertSublayer(gradientLayer, at: 0)
        
        let rainLayer = createRainDroplets()
        rainLayer.frame = pageView.bounds
        pageView.layer.addSublayer(rainLayer)
        
        let iconBackgroundView = UIView()
        iconBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iconBackgroundView.layer.cornerRadius = 60
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(iconBackgroundView)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: data.iconSystemName)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = data.titleText
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = data.descriptionText
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconBackgroundView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor, constant: -80),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 120),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 120),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -30),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -40)
        ])
        
        return pageView
    }
    
    private func createRainDroplets() -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitterLayer.emitterShape = .line
        
        let dropletCell = CAEmitterCell()
        dropletCell.contents = createDropletImage().cgImage
        dropletCell.birthRate = 8
        dropletCell.lifetime = 10.0
        dropletCell.velocity = 150
        dropletCell.velocityRange = 40
        dropletCell.yAcceleration = 80
        dropletCell.scale = 0.4
        dropletCell.scaleRange = 0.2
        dropletCell.alphaSpeed = -0.08
        dropletCell.alphaRange = 0.4
        
        emitterLayer.emitterCells = [dropletCell]
        return emitterLayer
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
            
            UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.5).setFill()
            path.fill()
        }
    }
    
    @objc private func continueTapped() {
        if currentPageIndex < onboardingPages.count - 1 {
            currentPageIndex += 1
            let xOffset = CGFloat(currentPageIndex) * view.bounds.width
            scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
            pageControl.currentPage = currentPageIndex
            
            if currentPageIndex == onboardingPages.count - 1 {
                continueButton.setTitle("Get Started", for: .normal)
            }
        } else {
            completeOnboarding()
        }
    }
    
    @objc private func skipTapped() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss(animated: true)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.bounds.width)
        currentPageIndex = Int(pageIndex)
        pageControl.currentPage = currentPageIndex
        
        if currentPageIndex == onboardingPages.count - 1 {
            continueButton.setTitle("Get Started", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }
}

struct OnboardingPageData {
    let iconSystemName: String
    let titleText: String
    let descriptionText: String
    let backgroundColor: UIColor
}


