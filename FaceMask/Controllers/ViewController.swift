//
//  ViewController.swift
//  FaceMask
//
//  Created by Alley Pereira on 17/06/21.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController {

    let faceView = FaceView()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(maskLabel)

        maskLabel.backgroundColor = .darkGray
        maskLabel.text = "A label"

        configureCaptureSession()

        maxX = view.bounds.maxX
        midY = view.bounds.midY
        maxY = view.bounds.maxY

        session.startRunning()
    }

    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)

    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0

}

// MARK: - Video Processing methods
extension ViewController {
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
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}
