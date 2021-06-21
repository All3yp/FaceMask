//
//  FaceViewController.swift
//  FaceMask
//
//  Created by Alley Pereira on 17/06/21.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class FaceViewController: UIViewController {

    private var requests = [VNRequest]()
    let faceView = FaceView(frame: UIScreen.main.bounds)

    let widthX: CGFloat = UIScreen.main.bounds.width/2
    let heightY: CGFloat = UIScreen.main.bounds.height/10

    lazy var maskLabel: UILabel = UILabel(frame: CGRect(
        x: (view.frame.width - widthX)/2,
        y: (view.frame.width - heightY)/2 + 600,
        width: widthX,
        height: 60
    ))

    let session = AVCaptureSession()
    var sequenceHandler = VNSequenceRequestHandler()
    var previewLayer: AVCaptureVideoPreviewLayer!

    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)

    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(maskLabel)
        view.addSubview(faceView)

        maskLabel.backgroundColor = .darkGray
        maskLabel.text = "A label"

        configureCaptureSession()
        requestModel()

        maxX = view.bounds.maxX
        midY = view.bounds.midY
        maxY = view.bounds.maxY

        session.startRunning()
    }

}

// MARK: - Video Processing methods
extension FaceViewController {
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }

        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }

        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        // Add the video output to the capture session
        session.addOutput(videoOutput)

        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
extension FaceViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // 1. Get the image buffer from the passed in sample buffer.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // 2. Create a face detection request to detect face bounding boxes and pass the results to a completion handler.
        let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace)

        // 3. Use your previously defined sequence request handler to perform your face detection request on the image. The orientation parameter tells the request handler what the orientation of the input image is.
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])

        do {
            try handler.perform(requests)
        } catch {
            print(error)
        }
    }

    func detectedFace(request: VNRequest, error: Error?) {
        // 1. Extract the first result from the array of face observation results.
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
        else {
            // 2. Clear the FaceView if something goes wrong or no face is detected.
            faceView.clear()
            return
        }

        // 3. Set the bounding box to draw in the FaceView after converting it from the coordinates in the VNFaceObservation.
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)

        // 4. Call setNeedsDisplay() to make sure the FaceView is redrawn.
        DispatchQueue.main.async {
            self.faceView.setNeedsDisplay()
        }
    }

    func convert(rect: CGRect) -> CGRect {
        // 1. Use a handy method from AVCaptureVideoPreviewLayer to convert a normalized origin to the preview layer’s coordinate system.
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)

        // 2. Then use the same handy method along with some nifty Core Graphics extensions to convert the normalized size to the preview layer’s coordinate system.
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

        // 3. Create a CGRect using the new origin and size.
        return CGRect(origin: origin, size: size.cgSize)
    }

    func requestModel() {

        do {

            let classifier = try FaceMaskClassifier(configuration: MLModelConfiguration())
            let visionModel = try VNCoreMLModel(for: classifier.model)

            let objectRecognition = VNCoreMLRequest(model: visionModel,
                                                    completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    _ = request.results
                })
            })
            self.requests = [objectRecognition]

        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
    }
    
}
