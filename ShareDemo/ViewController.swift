//
//  ViewController.swift
//  ShareDemo
//
//  Created by Shagun Madhikarmi on 07/05/2023.
//

import UIKit

final class ViewController: UIViewController {
    private let urlTextField = UITextField()

    // MARK: - Init & Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View lifecycle

    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        view.backgroundColor = .gray
        view.addSubview(urlTextField)
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            urlTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        urlTextField.text = "Hello World"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUrl()
    }

    // MARK: - Setup

    func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setUrl),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc func setUrl() {
        if let incomingURL = UserDefaults().value(forKey: "incomingURL") as? String {
            urlTextField.text = incomingURL
            UserDefaults().removeObject(forKey: "incomingURL")
        }
    }
}
