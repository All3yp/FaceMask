//
//  FaceDetection.swift
//  FaceMask
//
//  Created by Alley Pereira on 23/06/21.
//

import CoreML
import Vision
import AVFoundation
import UIKit

protocol FaceDetectionDelegate: AnyObject {
    func didDetectFace(_ hasFace: Bool)
}

class FaceDetection {

    // MARK: - Properties

    let faceView = FaceView(frame: UIScreen.main.bounds)

    private let previewLayer: AVCaptureVideoPreviewLayer?

    weak var delegate: FaceDetectionDelegate?

    private var sequenceHandler = VNSequenceRequestHandler()

    // MARK: - Methods

    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    func executeRequest(on sampleBuffer: CMSampleBuffer) {

        let detectFaceRequest = createRequest()

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func createRequest() -> VNDetectFaceRectanglesRequest {
        VNDetectFaceRectanglesRequest(completionHandler: detectedFace)
    }

    private func detectedFace(request: VNRequest, error: Error?) {

        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
        else {
            faceView.clear()
            //nao tem rosto
            delegate?.didDetectFace(false)
            return
        }

        //tem rosto
        delegate?.didDetectFace(true)

        let box = result.boundingBox

        guard let convertResult = convert(rect: box) else { return }

        faceView.boundingBox = convertResult

        DispatchQueue.main.async {
            self.faceView.setNeedsDisplay()
        }
    }

    private func convert(rect: CGRect) -> CGRect? {
        guard let previewLayer = previewLayer else { return nil }

        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

        return CGRect(origin: origin, size: size.cgSize)
    }
}
