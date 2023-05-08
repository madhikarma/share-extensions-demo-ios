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

    // MARK: - Init & Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

            } else {
                print("bad share data")
            }

            //        openMainApp()
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
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
