//
//  TaskEditViewController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: TaskEditViewOutput!
    
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Новая задача"
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
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    
        let saveButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        saveButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = saveButton
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        descriptionTextView.scrollIndicatorInsets = descriptionTextView.contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        descriptionTextView.contentInset = .zero
        descriptionTextView.scrollIndicatorInsets = .zero
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
        
        self.title = "Редактирование"
        titleTextField.text = title
        
        if let description = description {
            descriptionTextView.text = description
            descriptionPlaceholder.isHidden = true
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
 
        let saveButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        saveButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = saveButton
        
        titleTextField.isEnabled = true
        descriptionTextView.isEditable = true
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
