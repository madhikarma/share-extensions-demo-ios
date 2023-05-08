//
//  ViewController.swift
//  ShareDemo
//
//  Created by Shagun Madhikarmi on 07/05/2023.
//

import UIKit

final class ViewController: UIViewController {
    private let urlTextField = UITextField()

    private let imageView = UIImageView()

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

        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: urlTextField.bottomAnchor),

        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUrl()
        setImage()
    }

    // MARK: - Setup

    func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUI),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Actions

    private func setUrl() {
        if let incomingURL = userDefaults.value(forKey: urlDefaultName) as? String {
            urlTextField.text = incomingURL
//            userDefaults.removeObject(forKey: urlDefaultName)
        }
    }

    @objc func updateUI() {
        setUrl()
        setImage()
    }

    private func setImage() {
        if let incomingImageData = userDefaults.value(forKey: imageDefaultName) as? Data {
            let decoded = try! PropertyListDecoder().decode(Data.self, from: incomingImageData)
            let image = UIImage(data: decoded)
            imageView.image = image
//            defaults.removeObject(forKey: "incomingImage")
        } else {
//            let path = URL.urlInDocumentsDirectory(with: "shareImage.jpg").path
//            let image = UIImage(contentsOfFile: path)
//            imageView.image = image
//            defaults.removeObject(forKey: "incomingImage")
        }

        if let text = userDefaults.value(forKey: textDefaultName) as? String {
            urlTextField.text = text
//            defaults.removeObject(forKey: textDefaultName)
        }
    }
}
