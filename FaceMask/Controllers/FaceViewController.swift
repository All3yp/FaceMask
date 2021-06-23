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

    let camera = Camera()

    lazy var faceDetection = FaceDetection(previewLayer: camera.previewLayer)

    let maskDetection = MaskDetection()

//    var hasFace: Bool = false

    // MARK: - View configuration
    let widthX: CGFloat = UIScreen.main.bounds.width/2
    let heightY: CGFloat = UIScreen.main.bounds.height/10

    lazy var maskLabel: UILabel = UILabel(frame: CGRect(
        x: (view.frame.width - widthX)/2,
        y: (view.frame.width - heightY)/2 + 600,
        width: widthX,
        height: 60
    ))

    override func viewDidLoad() {
        super.viewDidLoad()

        camera.configureCamera(bounds: view.bounds, delegate: self)

        view.layer.insertSublayer(camera.previewLayer, at: 0)

        view.addSubview(maskLabel)
        view.addSubview(faceDetection.faceView)

        maskLabel.font = UIFont.systemFont(ofSize: 25)

//        faceDetection.delegate = self
        maskDetection.delegate = self
    }

}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
extension FaceViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        DispatchQueue.main.async { [weak self] in
            self?.faceDetection.executeRequest(on: sampleBuffer)
        }

//        if hasFace {
            self.maskDetection.executeRequest(on: sampleBuffer)
//        }
    }

}

extension FaceViewController: MaskDetectionDelegate {

    func didDetectMask(identifier: String, confidence: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.maskLabel.text = "\(identifier) \(confidence)"

            if identifier == "with_mask" {
                self?.maskLabel.backgroundColor = .systemGreen
            } else {
                self?.maskLabel.backgroundColor = .systemRed
            }
        }
    }

}

//extension FaceViewController: FaceDetectionDelegate {
//    func didDetectFace(_ hasFace: Bool) {
//        maskLabel.isHidden = !hasFace
//        self.hasFace = hasFace
//    }
//}
