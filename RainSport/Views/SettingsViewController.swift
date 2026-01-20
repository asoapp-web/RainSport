import UIKit
import WebKit
import StoreKit
import Photos
import AVFoundation

class SettingsViewController: UIViewController {
    
    private let scrollContainerView = UIScrollView()
    private let contentStackView = UIStackView()
    private let rainPhotoManager = RainProfilePhotoManager.shared
    private var rainProfilePhotoView: UIImageView?
    private var rainProfilePhotoButton: UIButton?
    private var rainDeletePhotoButton: UIButton?
    private var rainProfilePhotoContainer: UIView?
    private var rainImagePickerCoordinator: RainImagePickerCoordinator?
    
    var onDeleteAllData: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupGradientBackground()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rainPhotoManager.rainLoadPhoto()
        rainUpdateProfilePhotoView()
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
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.distribution = .fill
        scrollContainerView.addSubview(contentStackView)
        
        rainSetupProfilePhotoSection()
        
        let rateButton = createSettingsButton(
            title: "Rate Application",
            subtitle: "Share your feedback",
            iconName: "star.fill"
        )
        rateButton.addTarget(self, action: #selector(rateAppTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(rateButton)
        
        let shareButton = createSettingsButton(
            title: "Share Application",
            subtitle: "Tell your friends",
            iconName: "square.and.arrow.up.fill"
        )
        shareButton.addTarget(self, action: #selector(shareAppTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(shareButton)
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        contentStackView.addArrangedSubview(spacerView)
        
        let deleteButton = createDangerButton(
            title: "Delete All Data",
            subtitle: "Remove all training sessions"
        )
        deleteButton.addTarget(self, action: #selector(deleteAllDataTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -32)
        ])
    }
    
    private func createSettingsButton(title: String, subtitle: String, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .left
        
        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.3)
        iconBackgroundView.layer.cornerRadius = 25
        iconBackgroundView.isUserInteractionEnabled = false
        button.addSubview(iconBackgroundView)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isUserInteractionEnabled = false
        iconBackgroundView.addSubview(iconImageView)
        
        let textStackView = UIStackView()
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.isUserInteractionEnabled = false
        button.addSubview(textStackView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        textStackView.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.font = .systemFont(ofSize: 14)
        textStackView.addArrangedSubview(subtitleLabel)
        
        let chevronImageView = UIImageView()
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.isUserInteractionEnabled = false
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 80),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 50),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            textStackView.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            textStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }
    
    private func createDangerButton(title: String, subtitle: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.15)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.5).cgColor
        button.contentHorizontalAlignment = .left
        
        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.2)
        iconBackgroundView.layer.cornerRadius = 25
        iconBackgroundView.isUserInteractionEnabled = false
        button.addSubview(iconBackgroundView)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "trash.fill")
        iconImageView.tintColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isUserInteractionEnabled = false
        iconBackgroundView.addSubview(iconImageView)
        
        let textStackView = UIStackView()
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.isUserInteractionEnabled = false
        button.addSubview(textStackView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        textStackView.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = .systemFont(ofSize: 14)
        textStackView.addArrangedSubview(subtitleLabel)
        
        let chevronImageView = UIImageView()
        chevronImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        chevronImageView.tintColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.7)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.isUserInteractionEnabled = false
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 80),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 50),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            textStackView.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            textStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }
    
    @objc private func rateAppTapped() {
        if let windowScene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    @objc private func shareAppTapped() {
        let shareText = "Check out RainSport - track your training sessions in any weather!"
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityController, animated: true)
    }
    
    @objc private func deleteAllDataTapped() {
        let alert = UIAlertController(
            title: "Delete All Data?",
            message: "This will permanently delete all your training sessions and reset achievements. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserDefaults.standard.removeObject(forKey: "savedDrizzleWorkouts")
            UserDefaults.standard.removeObject(forKey: "rain_profile_photo_v1")
            UserDefaults.standard.synchronize()
            
            self?.rainPhotoManager.rainDeletePhoto()
            self?.rainUpdateProfilePhotoView()
            
            self?.onDeleteAllData?()
            
            let successAlert = UIAlertController(
                title: "Data Deleted",
                message: "All data has been successfully removed.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func rainSetupProfilePhotoSection() {
        if let existingContainer = rainProfilePhotoContainer {
            existingContainer.removeFromSuperview()
        }
        
        let profilePhotoView = createProfilePhotoSection()
        contentStackView.insertArrangedSubview(profilePhotoView, at: 0)
        rainProfilePhotoContainer = profilePhotoView
    }
    
    private func createProfilePhotoSection() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        containerView.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "PROFILE PHOTO"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        let photoContainer = UIView()
        photoContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(photoContainer)
        
        let photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 50
        photoImageView.clipsToBounds = true
        photoImageView.layer.borderWidth = 3
        photoImageView.layer.borderColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0).cgColor
        photoImageView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        if let photo = rainPhotoManager.rainProfilePhoto {
            photoImageView.image = photo
        } else {
            let placeholderIcon = UIImage(systemName: "person.circle.fill")
            photoImageView.image = placeholderIcon
            photoImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
            photoImageView.contentMode = .scaleAspectFit
        }
        
        photoContainer.addSubview(photoImageView)
        self.rainProfilePhotoView = photoImageView
        
        let addButton = UIButton(type: .system)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle(rainPhotoManager.rainProfilePhoto != nil ? "CHANGE PHOTO" : "ADD PHOTO", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.6)
        addButton.layer.cornerRadius = 12
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.addTarget(self, action: #selector(rainShowPhotoSourceAlert), for: .touchUpInside)
        containerView.addSubview(addButton)
        self.rainProfilePhotoButton = addButton
        
        let deleteButton = UIButton(type: .system)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("DELETE", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.clear
        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.borderWidth = 2
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        deleteButton.addTarget(self, action: #selector(rainDeletePhoto), for: .touchUpInside)
        deleteButton.isHidden = rainPhotoManager.rainProfilePhoto == nil
        containerView.addSubview(deleteButton)
        self.rainDeletePhotoButton = deleteButton
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            photoContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            photoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            photoContainer.widthAnchor.constraint(equalToConstant: 100),
            photoContainer.heightAnchor.constraint(equalToConstant: 100),
            
            photoImageView.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: photoContainer.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 100),
            photoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            addButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: photoContainer.trailingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            deleteButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12),
            deleteButton.leadingAnchor.constraint(equalTo: photoContainer.trailingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return containerView
    }
    
    @objc private func rainShowPhotoSourceAlert() {
        let alert = UIAlertController(title: "Select Photo Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.rainRequestCameraPermission()
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.rainRequestPhotoLibraryPermission()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = rainProfilePhotoButton
            popover.sourceRect = rainProfilePhotoButton?.bounds ?? .zero
        }
        
        present(alert, animated: true)
    }
    
    private func rainRequestCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            RainImagePicker.rainPresentImagePicker(sourceType: .camera, from: self, coordinator: &rainImagePickerCoordinator) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        self?.rainPhotoManager.rainSavePhoto(image)
                        self?.rainUpdateProfilePhotoView()
                    }
                }
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        RainImagePicker.rainPresentImagePicker(sourceType: .camera, from: self!, coordinator: &self!.rainImagePickerCoordinator) { image in
                            DispatchQueue.main.async {
                                if let image = image {
                                    self?.rainPhotoManager.rainSavePhoto(image)
                                    self?.rainUpdateProfilePhotoView()
                                }
                            }
                        }
                    }
                }
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    private func rainRequestPhotoLibraryPermission() {
        let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch authStatus {
        case .authorized, .limited:
            RainImagePicker.rainPresentImagePicker(sourceType: .photoLibrary, from: self, coordinator: &rainImagePickerCoordinator) { [weak self] image in
                DispatchQueue.main.async {
                    if let image = image {
                        self?.rainPhotoManager.rainSavePhoto(image)
                        self?.rainUpdateProfilePhotoView()
                    }
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        RainImagePicker.rainPresentImagePicker(sourceType: .photoLibrary, from: self!, coordinator: &self!.rainImagePickerCoordinator) { image in
                            DispatchQueue.main.async {
                                if let image = image {
                                    self?.rainPhotoManager.rainSavePhoto(image)
                                    self?.rainUpdateProfilePhotoView()
                                }
                            }
                        }
                    }
                }
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    @objc private func rainDeletePhoto() {
        rainPhotoManager.rainDeletePhoto()
        rainUpdateProfilePhotoView()
    }
    
    private func rainUpdateProfilePhotoView() {
        rainPhotoManager.rainLoadPhoto()
        
        if let photo = rainPhotoManager.rainProfilePhoto {
            rainProfilePhotoView?.image = photo
            rainProfilePhotoView?.contentMode = .scaleAspectFill
            rainProfilePhotoView?.tintColor = nil
        } else {
            let placeholderIcon = UIImage(systemName: "person.circle.fill")
            rainProfilePhotoView?.image = placeholderIcon
            rainProfilePhotoView?.tintColor = UIColor.white.withAlphaComponent(0.5)
            rainProfilePhotoView?.contentMode = .scaleAspectFit
        }
        
        rainProfilePhotoButton?.setTitle(rainPhotoManager.rainProfilePhoto != nil ? "CHANGE PHOTO" : "ADD PHOTO", for: .normal)
        rainDeletePhotoButton?.isHidden = rainPhotoManager.rainProfilePhoto == nil
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    private let webView = WKWebView()
    private let urlString: String
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let closeButton = UIButton(type: .system)
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadURL()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        closeButton.layer.cornerRadius = 8
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        view.addSubview(progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            progressView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func loadURL() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

