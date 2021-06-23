//
//  MaskDetection.swift
//  FaceMask
//
//  Created by Alley Pereira on 23/06/21.
//

import CoreML
import Vision
import AVFoundation
import UIKit

// Como usar o Vision:
// Request -> Handler -> Observation
/// Cria uma Request
/// Configura Completion pra Request
/// Cria Handler com a imagem (sampleBuffer ou cgimage)
/// Executa a Request com o Handler (perform)
/// Observation é retornada e tratada na Completion da Request

protocol MaskDetectionDelegate: AnyObject {
    func didDetectMask(identifier: String, confidence: Float)
}

class MaskDetection {

    weak var delegate: MaskDetectionDelegate?

    private let classifier: FaceMaskClassifier
    private let visionModel: VNCoreMLModel

    init() {
        self.classifier = try! FaceMaskClassifier(configuration: MLModelConfiguration())
        self.visionModel = try! VNCoreMLModel(for: classifier.model)
    }

    func executeRequest(on sampleBuffer: CMSampleBuffer) {

        let request = createRequest()

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    private func createRequest() -> VNCoreMLRequest {
        let request = VNCoreMLRequest(
            model: visionModel,
            completionHandler: detectedMaskCompletionHandler
        )
        return request
    }

    private func detectedMaskCompletionHandler(request: VNRequest, error: Error?) -> Void {
        //Tratar o retorno do classificador (observation)
        if let obs = request.results?.first as? VNClassificationObservation {
            print("🤖", obs.identifier, obs.confidence)

            delegate?.didDetectMask(identifier: obs.identifier, confidence: obs.confidence)
        }
    }

}
