import UIKit
import Combine

class AddTrainingViewController: UIViewController {
    
    private var workoutViewModel: WorkoutStorageViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollContainerView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let activityTextField = UITextField()
    private let durationTextField = UITextField()
    private let temperatureTextField = UITextField()
    private let notesTextView = UITextView()
    private let intensitySlider = UISlider()
    private let intensityValueLabel = UILabel()
    
    private var selectedWeatherCondition: WeatherConditionType = .rainy
    private var weatherButtonsArray: [UIButton] = []
    
    private let submitWorkoutButton = UIButton(type: .system)
    private let workoutTableView = UITableView()
    
    init(workoutViewModel: WorkoutStorageViewModel) {
        self.workoutViewModel = workoutViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Training Log"
        setupGradientBackground()
        setupViews()
        setupConstraints()
        setupObservers()
        setupKeyboardDismissal()
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
        contentStackView.spacing = 20
        contentStackView.distribution = .fill
        scrollContainerView.addSubview(contentStackView)
        
        let formContainer = createFormSection()
        contentStackView.addArrangedSubview(formContainer)
        
        workoutTableView.translatesAutoresizingMaskIntoConstraints = false
        workoutTableView.delegate = self
        workoutTableView.dataSource = self
        workoutTableView.backgroundColor = .clear
        workoutTableView.separatorStyle = .none
        workoutTableView.register(WorkoutCellView.self, forCellReuseIdentifier: "WorkoutCellView")
        contentStackView.addArrangedSubview(workoutTableView)
    }
    
    private func createFormSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        container.layer.cornerRadius = 16
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        container.addSubview(stackView)
        
        let activityLabel = createLabel(text: "Activity Name")
        stackView.addArrangedSubview(activityLabel)
        
        activityTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        activityTextField.textColor = .white
        activityTextField.layer.cornerRadius = 8
        activityTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        activityTextField.leftViewMode = .always
        activityTextField.attributedPlaceholder = NSAttributedString(
            string: "e.g. Running",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        activityTextField.translatesAutoresizingMaskIntoConstraints = false
        activityTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(activityTextField)
        
        let durationLabel = createLabel(text: "Duration (minutes)")
        stackView.addArrangedSubview(durationLabel)
        
        durationTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        durationTextField.textColor = .white
        durationTextField.keyboardType = .numberPad
        durationTextField.layer.cornerRadius = 8
        durationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        durationTextField.leftViewMode = .always
        durationTextField.attributedPlaceholder = NSAttributedString(
            string: "30",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        durationTextField.translatesAutoresizingMaskIntoConstraints = false
        durationTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(durationTextField)
        
        let temperatureLabel = createLabel(text: "Temperature (°C)")
        stackView.addArrangedSubview(temperatureLabel)
        
        temperatureTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        temperatureTextField.textColor = .white
        temperatureTextField.keyboardType = .decimalPad
        temperatureTextField.layer.cornerRadius = 8
        temperatureTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        temperatureTextField.leftViewMode = .always
        temperatureTextField.attributedPlaceholder = NSAttributedString(
            string: "15",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        temperatureTextField.translatesAutoresizingMaskIntoConstraints = false
        temperatureTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(temperatureTextField)
        
        let weatherLabel = createLabel(text: "Weather Condition")
        stackView.addArrangedSubview(weatherLabel)
        
        let weatherButtonsContainer = createWeatherButtons()
        stackView.addArrangedSubview(weatherButtonsContainer)
        
        let intensityLabel = createLabel(text: "Intensity Level")
        stackView.addArrangedSubview(intensityLabel)
        
        let intensityContainer = UIStackView()
        intensityContainer.axis = .horizontal
        intensityContainer.spacing = 12
        
        intensitySlider.minimumValue = 1
        intensitySlider.maximumValue = 10
        intensitySlider.value = 5
        intensitySlider.tintColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        intensitySlider.addTarget(self, action: #selector(intensitySliderChanged), for: .valueChanged)
        intensityContainer.addArrangedSubview(intensitySlider)
        
        intensityValueLabel.text = "5"
        intensityValueLabel.textColor = .white
        intensityValueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        intensityValueLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        intensityContainer.addArrangedSubview(intensityValueLabel)
        
        stackView.addArrangedSubview(intensityContainer)
        
        let notesLabel = createLabel(text: "Notes")
        stackView.addArrangedSubview(notesLabel)
        
        notesTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        notesTextView.textColor = .white
        notesTextView.layer.cornerRadius = 8
        notesTextView.font = .systemFont(ofSize: 15)
        notesTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.addArrangedSubview(notesTextView)
        
        submitWorkoutButton.setTitle("Add Training Session", for: .normal)
        submitWorkoutButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        submitWorkoutButton.setTitleColor(.white, for: .normal)
        submitWorkoutButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitWorkoutButton.layer.cornerRadius = 12
        submitWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        submitWorkoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitWorkoutButton.addTarget(self, action: #selector(submitWorkoutTapped), for: .touchUpInside)
        stackView.addArrangedSubview(submitWorkoutButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    private func createWeatherButtons() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        container.addSubview(stackView)
        
        let weatherTypes = WeatherConditionType.allCases.prefix(4)
        for weatherType in weatherTypes {
            let button = UIButton(type: .system)
            button.setTitle(weatherType.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.backgroundColor = weatherType == selectedWeatherCondition ? 
                UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0) : 
                UIColor(white: 1.0, alpha: 0.15)
            button.layer.cornerRadius = 8
            button.tag = WeatherConditionType.allCases.firstIndex(of: weatherType) ?? 0
            button.addTarget(self, action: #selector(weatherButtonTapped(_:)), for: .touchUpInside)
            weatherButtonsArray.append(button)
            stackView.addArrangedSubview(button)
        }
        
        let stackView2 = UIStackView()
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        stackView2.axis = .horizontal
        stackView2.spacing = 8
        stackView2.distribution = .fillEqually
        container.addSubview(stackView2)
        
        let remainingWeatherTypes = Array(WeatherConditionType.allCases.dropFirst(4))
        for weatherType in remainingWeatherTypes {
            let button = UIButton(type: .system)
            button.setTitle(weatherType.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            button.layer.cornerRadius = 8
            button.tag = WeatherConditionType.allCases.firstIndex(of: weatherType) ?? 0
            button.addTarget(self, action: #selector(weatherButtonTapped(_:)), for: .touchUpInside)
            weatherButtonsArray.append(button)
            stackView2.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView2.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            stackView2.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView2.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView2.heightAnchor.constraint(equalToConstant: 40),
            stackView2.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
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
            contentStackView.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -32),
            
            workoutTableView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupObservers() {
        workoutViewModel.$drizzleWorkouts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.workoutTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func weatherButtonTapped(_ sender: UIButton) {
        selectedWeatherCondition = WeatherConditionType.allCases[sender.tag]
        
        for button in weatherButtonsArray {
            button.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        }
        sender.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
    }
    
    @objc private func intensitySliderChanged() {
        let value = Int(intensitySlider.value)
        intensityValueLabel.text = "\(value)"
    }
    
    @objc private func submitWorkoutTapped() {
        guard let activityName = activityTextField.text, !activityName.isEmpty,
              let durationText = durationTextField.text, let duration = Int(durationText),
              let tempText = temperatureTextField.text, let temperature = Double(tempText) else {
            showErrorAlert(message: "Please fill in all required fields")
            return
        }
        
        let workout = DrizzleWorkoutModel(
            activityName: activityName,
            durationMinutes: duration,
            weatherCondition: selectedWeatherCondition,
            temperatureCelsius: temperature,
            intensityLevel: Int(intensitySlider.value),
            notes: notesTextView.text ?? ""
        )
        
        workoutViewModel.appendNewWorkout(workout)
        clearForm()
        showSuccessAlert()
    }
    
    private func clearForm() {
        activityTextField.text = ""
        durationTextField.text = ""
        temperatureTextField.text = ""
        notesTextView.text = ""
        intensitySlider.value = 5
        intensityValueLabel.text = "5"
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Training session added!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddTrainingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutViewModel.drizzleWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCellView", for: indexPath) as! WorkoutCellView
        let workout = workoutViewModel.drizzleWorkouts[indexPath.row]
        cell.configureWithWorkout(workout)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workout = workoutViewModel.drizzleWorkouts[indexPath.row]
            workoutViewModel.removeWorkoutById(workout.id)
        }
    }
}

class WorkoutCellView: UITableViewCell {
    
    private let containerView = UIView()
    private let activityLabel = UILabel()
    private let weatherIconLabel = UILabel()
    private let durationLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let intensityLabel = UILabel()
    private let notesLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        
        activityLabel.font = .systemFont(ofSize: 16, weight: .bold)
        activityLabel.textColor = .white
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityLabel)
        
        weatherIconLabel.font = .systemFont(ofSize: 14)
        weatherIconLabel.textColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        weatherIconLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(weatherIconLabel)
        
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .white.withAlphaComponent(0.8)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(durationLabel)
        
        temperatureLabel.font = .systemFont(ofSize: 14)
        temperatureLabel.textColor = .white.withAlphaComponent(0.8)
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(temperatureLabel)
        
        intensityLabel.font = .systemFont(ofSize: 14)
        intensityLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(intensityLabel)
        
        notesLabel.font = .systemFont(ofSize: 13)
        notesLabel.textColor = .white.withAlphaComponent(0.7)
        notesLabel.numberOfLines = 2
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(notesLabel)
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .white.withAlphaComponent(0.6)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            activityLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            activityLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            weatherIconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            weatherIconLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            durationLabel.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            temperatureLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 4),
            temperatureLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            intensityLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 4),
            intensityLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            notesLabel.topAnchor.constraint(equalTo: intensityLabel.bottomAnchor, constant: 6),
            notesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            notesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configureWithWorkout(_ workout: DrizzleWorkoutModel) {
        activityLabel.text = workout.activityName
        weatherIconLabel.text = workout.weatherCondition.rawValue
        durationLabel.text = "Duration: \(workout.durationMinutes) min"
        temperatureLabel.text = "Temp: \(String(format: "%.1f", workout.temperatureCelsius))°C"
        intensityLabel.text = "Intensity: \(workout.intensityLevel)/10"
        
        if workout.notes.isEmpty {
            notesLabel.text = ""
            notesLabel.isHidden = true
        } else {
            notesLabel.text = "Notes: \(workout.notes)"
            notesLabel.isHidden = false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        dateLabel.text = formatter.string(from: workout.timestamp)
    }
}

