//
//  TaskEditViewController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditViewController: UIViewController {
    
    enum Mode {
        case view
        case edit
        case create
    }
    
    // MARK: - Properties
    
    private let mode: Mode
    private var lastKeyboardBottomInset: CGFloat = 0
    
    var presenter: TaskEditViewOutput!
    
    // MARK: - Navigation Items
    
    private lazy var cancelBarButton = UIBarButtonItem(
        title: "Отмена",
        style: .plain,
        target: self,
        action: #selector(cancelTapped)
    )
    
    private lazy var saveBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        button.tintColor = .systemYellow
        return button
    }()
    
    private lazy var editBarButton = UIBarButtonItem(
        title: "Редактировать",
        style: .plain,
        target: self,
        action: #selector(didTapEdit)
    )
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - UI Components
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Название задачи"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.borderStyle = .none
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        return textView
    }()
    
    private lazy var descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Описание (необязательно)"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .placeholderText
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.mode = .edit
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyMode()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // В режиме просмотра клавиатура не нужна
        guard mode != .view else { return }
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleTextField)
        view.addSubview(separatorView)
        view.addSubview(descriptionTextView)
        view.addSubview(descriptionPlaceholder)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            separatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionTextView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor)
        ])
        
        setupKeyboardHandling()
    }
    
    private func applyMode() {
        switch mode {
        case .view:
            title = "Задача"
            setEditingEnabled(false)
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = editBarButton
            
        case .edit:
            title = "Редактирование"
            setEditingEnabled(true)
            
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.rightBarButtonItem = saveBarButton
            
        case .create:
            title = "Новая задача"
            setEditingEnabled(true)
            
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.rightBarButtonItem = saveBarButton
        }
    }
    
    private func setEditingEnabled(_ enabled: Bool) {
        titleTextField.isUserInteractionEnabled = enabled
        descriptionTextView.isEditable = enabled
        
        // чтобы поле не "серело"
        titleTextField.isEnabled = true
        descriptionTextView.isSelectable = true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        presenter.didTapCancel()
    }
    
    @objc private func saveTapped() {
        let title = titleTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        presenter.didTapSave(title: title, description: description)
    }
    
    @objc private func didTapEdit() {
        presenter.didTapEdit()
    }
    
    @objc private func dismissKeyboard() {
        if descriptionTextView.isFirstResponder { return }
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard mode != .view else { return }
        guard descriptionTextView.isFirstResponder else { return } // ✅ важно
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom)
        
        guard abs(bottomInset - lastKeyboardBottomInset) > 0.5 else { return }
        lastKeyboardBottomInset = bottomInset
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))
        
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.descriptionTextView.contentInset.bottom = bottomInset
            if #available(iOS 13.0, *) {
                self.descriptionTextView.verticalScrollIndicatorInsets.bottom = bottomInset
            } else {
                self.descriptionTextView.scrollIndicatorInsets.bottom = bottomInset
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard mode != .view else { return }
        
        guard lastKeyboardBottomInset > 0 else { return }
        lastKeyboardBottomInset = 0
        
        let userInfo = notification.userInfo
        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))
        
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            if #available(iOS 13.0, *) {
                self.descriptionTextView.verticalScrollIndicatorInsets = .zero
            } else {
                self.descriptionTextView.scrollIndicatorInsets = .zero
            }            }
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - TaskEditViewInput

extension TaskEditViewController: TaskEditViewInput {
    
    func displayTask(title: String, description: String?) {
        ThreadSafetyHelpers.assertMainThread()
        
        titleTextField.text = title
        
        if let description, !description.isEmpty {
            descriptionTextView.text = description
            descriptionPlaceholder.isHidden = true
        } else {
            descriptionTextView.text = ""
            descriptionPlaceholder.isHidden = false
        }
    }
    
    func showLoading() {
        ThreadSafetyHelpers.assertMainThread()
        
        let loadingItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = loadingItem
        activityIndicator.startAnimating()
        
        titleTextField.isEnabled = false
        descriptionTextView.isEditable = false
    }
    
    func hideLoading() {
        ThreadSafetyHelpers.assertMainThread()
        
        activityIndicator.stopAnimating()
        
        applyMode()
        
        titleTextField.isEnabled = true
        descriptionTextView.isEditable = (mode != .view)
    }
    
    func showError(message: String) {
        ThreadSafetyHelpers.assertMainThread()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func dismiss() {
        ThreadSafetyHelpers.assertMainThread()
    }
}

// MARK: - UITextFieldDelegate

extension TaskEditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard mode != .view else { return false }
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension TaskEditViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}
