//
//  ImagePicker.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.08.20.
//

import UIKit

protocol ImagePickerDelegate {
    func didSelect(image: UIImage?)
}

class ImagePicker: NSObject {
    var delegate: ImagePickerDelegate?

    private let targetSize = CGSize(width: 400 / UIScreen.main.scale, height: 400 / UIScreen.main.scale)
    private let imagePicker: UIImagePickerController

    override init() {
        imagePicker = UIImagePickerController()
        super.init()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    func present(_ viewController: UIViewController) {
        viewController.present(imagePicker, animated: true)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.didSelect(image: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else { return }

        let size = image.size
        if size.width <= targetSize.width, size.height <= targetSize.height {
            delegate?.didSelect(image: image)
            return
        }

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        delegate?.didSelect(image: newImage)
    }
}

extension ImagePicker: UINavigationControllerDelegate {}
