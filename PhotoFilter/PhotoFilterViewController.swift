import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ColorFilter: Operation {
    var inputImage: UIImage
    var outputImage: UIImage?
    
    var brightness: Float
    var contrast: Float
    var saturation: Float
    
    let context = CIContext(options: nil)
    
    init(image: UIImage, brightness: Float, contrast: Float, saturation: Float) {
        self.inputImage = image
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        
        super.init()
    }
    
    override func start() {
        if isCancelled {
            print("Dropping colorFilter, canceled")
        }
        super.start()
    }
    override func main() {
        if !isCancelled {
            guard let cgImage = inputImage.cgImage else { return }
            
            let ciImage = CIImage(cgImage: cgImage)
            
            let filter = CIFilter.colorControls() // Like a recipe

            filter.inputImage = ciImage
            filter.brightness = brightness
            filter.contrast = contrast
            filter.saturation = saturation
            
            // CIImage -> CGImage -> UIImage
            guard let outputCIImage = filter.outputImage else { return }

            // Rendering the image (actually baking the cookies)
            guard let outputCGImage = context.createCGImage(outputCIImage,
                                                            from: CGRect(origin: .zero, size: inputImage.size)) else { return }
            outputImage = UIImage(cgImage: outputCGImage)
        } else {
            print("Canceled")
        }
    }
}

class PhotoFilterViewController: UIViewController {

    private var context = CIContext(options: nil)
    private var imageQueue = OperationQueue()
    
    private var originalImage: UIImage? {
        didSet {

            // scale down the image

//            guard let originalImage = originalImage else { return }
//
//            // Height and width
//            var scaledSize = imageView.bounds.size
//
//            // 1x, 2x, or 3x
//            let scale = UIScreen.main.scale
//
//            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
//            print("size: \(scaledSize)")
//
//            // Update the display with the scaled image
//            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            scaledImage = originalImage
        }
    }

    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    private var operationQueue = OperationQueue()
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        print("Bounds: \(UIScreen.main.bounds)")
        print("Scale: \(UIScreen.main.scale)")
        
//        let filter = CIFilter.colorControls() // Like a recipe
//        print(filter)
//        print(filter.attributes)
        
        originalImage = imageView.image
        operationQueue.maxConcurrentOperationCount = 1
    
	}
    
    func updateImage() {
//        if let scaledImage = originalImage {
        if let originalImage = originalImage {

//            imageView.image = filterImage(scaledImage)
            print("colorFilter")
            let colorFilter = ColorFilter(image: originalImage,
                                     brightness: brightnessSlider.value,
                                     contrast: contrastSlider.value,
                                     saturation: saturationSlider.value)
            
            
            
            let updateUIBlock = BlockOperation {
                print("update")
                if let image = colorFilter.outputImage {
                    self.imageView.image = image
                }
            }
            updateUIBlock.addDependency(colorFilter)
            operationQueue.cancelAllOperations()

            operationQueue.addOperation(colorFilter)
            OperationQueue.main.addOperation(updateUIBlock)
            
            
            
        } else {
            imageView.image = nil // reseting image to nothing
        }
    }

    func filterImage(_ image: UIImage) -> UIImage? {
        print("filter")
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls() // Like a recipe

        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        // CIImage -> CGImage -> UIImage
        guard let outputCIImage = filter.outputImage else { return nil }

        // Rendering the image (actually baking the cookies)
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    
	// MARK: Actions
	
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        showImagePicker()
    }
	
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        
        guard let originalImage = originalImage else { return }
        guard let processedImage = filterImage(originalImage.flattened) else { return }

        PHPhotoLibrary.requestAuthorization { (status) in

            guard status == .authorized else { fatalError("User did not authorize app to save photos") }

            // Let the library know we are going to make changes
            PHPhotoLibrary.shared().performChanges({

                // Make a new photo creation request
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)

            }, completionHandler: { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
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
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension PhotoFilterViewController: UINavigationControllerDelegate {
    
}
