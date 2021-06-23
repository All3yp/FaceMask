//
//  DetectFace.swift
//  FaceMask
//
//  Created by Alley Pereira on 23/06/21.
//

import CoreML
import Vision
import AVFoundation

class Camera {

    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    var previewLayer: AVCaptureVideoPreviewLayer!

    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0

    let session = AVCaptureSession()

    func configureCamera(bounds: CGRect, delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {

        self.delegate = delegate

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(delegate, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        session.addOutput(videoOutput)

        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds

        maxX = bounds.maxX
        midY = bounds.midY
        maxY = bounds.maxY

        session.startRunning()
    }
}
