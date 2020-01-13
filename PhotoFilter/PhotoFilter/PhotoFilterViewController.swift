import UIKit
import CoreImage
import Photos

class PhotoFilterViewController: UIViewController {

	var originalImage: UIImage? {
		didSet {
			guard let originalImage = originalImage else { return }

			// Height and width
			var scaledSize = imageView.bounds.size

			// 1x, 2x, or 3x
			let scale = UIScreen.main.scale

			scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
			print("size: \(scaledSize)")
			scaledImage = originalImage.imageByScaling(toSize: scaledSize)
		}
	}

	var scaledImage: UIImage? {
		didSet {
			updateImage()
		}
	}
	
//	private var filter = CIFilter(name: "CIColorControls")!
	private var filter = CIFilter(name: "CIPinchDistortion")!
	private var context = CIContext(options: nil)
	private var imagePosition = CGPoint.zero
	
	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var contrastSlider: UISlider!
	@IBOutlet var saturationSlider: UISlider!
	@IBOutlet var imageView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()

		originalImage = imageView.image
		
		// PanGesture
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGesture:)))
		imageView.addGestureRecognizer(panGesture)
		imageView.isUserInteractionEnabled = true
	}

	@objc private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
		let location = panGesture.location(in: imageView)
		if panGesture.state == .changed {
			
			print("Pos: \(location)")
			imagePosition = location
			updateImage()
		} // TODO: deal with .began and .ended
	}
	
	
	private func filterImage(_ image: UIImage) -> UIImage {
		guard let cgImage = image.cgImage else { return image }
		
		let ciImage = CIImage(cgImage: cgImage)
		
		// Set up the filter
		
		// k = constant
		filter.setValue(ciImage, forKey: kCIInputImageKey)
	//		filter.setValue(brightnessSlider.value, forKey: kCIInputRadiusKey)
	//		filter.setValue(contrastSlider.value, forKey: kCIInputScaleKey)
		filter.setValue(300, forKey: kCIInputRadiusKey)
		filter.setValue(0.8, forKey: kCIInputScaleKey)

		let scale = UIScreen.main.scale
		let position = CGPoint(x: imagePosition.x * scale, y: imagePosition.y * scale)
		let center = CIVector(cgPoint: position)
		
		filter.setValue(center, forKey: kCIInputCenterKey)
		
		// Get output
		guard let outputCIImage = filter.outputImage else { return image }
		
		// Render the image
		guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return image }
		
		return UIImage(cgImage: outputCGImage)
	}
	
	
	// MARK: Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		presentImagePickerController()
	}

	private func presentImagePickerController() {
		guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
			print("The photo library is not available")
			return
		}
		
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		
		present(imagePicker, animated: true, completion: nil)
	}
	
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {

		guard let originalImage = originalImage else { return }

		let processedImage = filterImage(originalImage.flattened)

		PHPhotoLibrary.requestAuthorization { (status) in

			guard status == .authorized else { return }

			// Let the library know we are going to make changes
			PHPhotoLibrary.shared().performChanges({

				// Make a new photo creation request

				PHAssetCreationRequest.creationRequestForAsset(from: processedImage)

			}, completionHandler: { (success, error) in

				if let error = error {
					NSLog("Error saving photo: \(error)")
					return
				}

				DispatchQueue.main.async {
					print("Saved image!")
				}
			})
		}
		
	}

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {
		updateImage()
	}

	@IBAction func contrastChanged(_ sender: Any) {
		updateImage()
	}

	@IBAction func saturationChanged(_ sender: Any) {
		updateImage()
	}

	// DRY: Don't Repeat Yourself

	private func updateImage() {
		if let scaledImage = scaledImage {
			imageView.image = filterImage(scaledImage)
		} else {
			imageView.image = nil
		}
	}
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		// First use the editted (if it exists), otherwise use the original
		if let image = info[.editedImage] as? UIImage {
			originalImage = image
		} else if let image = info[.originalImage] as? UIImage {
			originalImage = image
		}
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension PhotoFilterViewController: UINavigationControllerDelegate {

}
