//
//  ShareViewController.swift
//  ShareDemoExt
//
//  Created by Shagun Madhikarmi on 07/05/2023.
//

import CoreServices
import Social
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private let typeText = String(kUTTypeText)
    private let typeURL = String(kUTTypeURL)
    private let typeImage = String(kUTTypeImage)
    private let textLabel = UILabel()

    // MARK: - Init & Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        textLabel.text = "Share extension"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 1
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first
        else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(typeText) {
            handleIncomingText(itemProvider: itemProvider)
        } else if itemProvider.hasItemConformingToTypeIdentifier(typeURL) {
            handleIncomingURL(itemProvider: itemProvider)
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) ||
            itemProvider.hasItemConformingToTypeIdentifier(UTType.png.identifier) ||
            itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        {
            handleIncomingImage(itemProvider: itemProvider)
        } else {
            print("Error: No url or text found")
//            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    // MARK: - Setup

    private func handleIncomingText(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: typeText, options: nil) { item, error in
            if let error = error { print("Text-Error: \(error.localizedDescription)") }

            if let text = item as? String {
//                do { // 2.1
//                    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//                    let matches = detector.matches(
//                        in: text,
//                        options: [],
//                        range: NSRange(location: 0, length: text.utf16.count)
//                    )
//                    // 2.2
//                    if let firstMatch = matches.first, let range = Range(firstMatch.range, in: text) {
//                        self.saveURLString(String(text[range]))
//                    }
//                } catch {
//                    print("Do-Try Error: \(error.localizedDescription)")
//                }
                self.saveURLString(text)
            }

//            self.openMainApp()
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingURL(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: typeURL, options: nil) { item, error in
            if let error = error { print("URL-Error: \(error.localizedDescription)") }

            if let url = item as? NSURL, let urlString = url.absoluteString {
                self.saveURLString(urlString)
            }

//            self.openMainApp()
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingImage(itemProvider: NSItemProvider) {
        DispatchQueue.main.async {
            self.textLabel.text = "Loading image..."
        }

        itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
            if let error = error { print("Image-Error: \(error.localizedDescription)") }

            var image: UIImage?
            if let someURL = item as? URL {
                image = UIImage(contentsOfFile: someURL.path)
            } else if let someImage = item as? UIImage {
                image = someImage
            }

            if let someImage = image {
//                guard let compressedImagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("shareImage.jpg", isDirectory: false) else {
//                    return
//                }
                ////
                ////
                ///
                let originalImage = someImage
                let resizingFactor = 100 / originalImage.size.height
                let newImage = UIImage(cgImage: originalImage.cgImage!, scale: originalImage.scale / resizingFactor, orientation: .up)
                // let newImage = someImage
                let compressedImageData = newImage.jpegData(compressionQuality: 1)
//                guard (try? compressedImageData?.write(to: compressedImagePath)) != nil else {
//                    return
//                }

//                try! compressedImageData?.write(to: compressedImagePath, options: .atomic)

                let encoded = try! PropertyListEncoder().encode(compressedImageData)
                userDefaults.set(encoded, forKey: imageDefaultName)
                userDefaults.synchronize()

                let url = URL(string: "https://mocki.io/v1/797c201d-bdbb-4c8f-ba0c-b06ea30a0e45")!
                let urlRequest = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    if let error = error {
                        print("error: \(error)")
                        DispatchQueue.main.async {
                            self.textLabel.text = "Error: \(error.localizedDescription)"
                        }
                    }

                    var result: Result<String, Error>?
                    var jsonObject: [String: AnyObject]?
                    if let responseData = data {
                        do {
                            jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .fragmentsAllowed) as? [String: AnyObject]
                            print("json: \(String(describing: jsonObject))")
                            if let status = jsonObject?["status"] as? String {
                                result = .success(status)
                                DispatchQueue.main.async {
                                    self.textLabel.text = "Complete: \(status)"
                                }
                            }
                        } catch let jsonError {
                            print("jsonError: \(jsonError)")
                            result = .failure(jsonError)
                        }
                    }

                    DispatchQueue.main.async {
                        let alertViewController: UIAlertController
                        switch result {
                        case let .success(text):
                            let message = "Success: \(text) \(String(describing: jsonObject?.description))"
                            self.textLabel.text = message
                            alertViewController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                        case let .failure(error):
                            let message = "Error: \(error.localizedDescription)"
                            self.textLabel.text = message
                            alertViewController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        case .none:
                            let message = "Unknown"
                            self.textLabel.text = message
                            alertViewController = UIAlertController(title: "Unknown", message: message, preferredStyle: .alert)
                        }

                        let okAction = UIAlertAction(title: "Open app", style: .default) { _ in
//                            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                            let url = URL(string: appURL)!
                            self.openURL(url)
                        }

                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                        }
                        alertViewController.addAction(okAction)
                        alertViewController.addAction(cancelAction)
                        self.present(alertViewController, animated: true)
                    }
                }
                task.resume()

            } else {
                print("bad share data")
            }

            //        openMainApp()
        }
    }

    private func saveURLString(_ urlString: String) {
        userDefaults.set(urlString, forKey: urlDefaultName)
    }

    private func openMainApp() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: appURL) else { return }
            _ = self.openURL(url)
        })
    }

    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
