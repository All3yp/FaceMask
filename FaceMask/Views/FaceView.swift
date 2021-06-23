//
//  FaceView.swift
//  FaceMask
//
//  Created by Alley Pereira on 17/06/21.
//

import UIKit
import Vision

class FaceView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var leftEye: [CGPoint] = []
    var rightEye: [CGPoint] = []
    var leftEyebrow: [CGPoint] = []
    var rightEyebrow: [CGPoint] = []
    var nose: [CGPoint] = []
    var outerLips: [CGPoint] = []
    var innerLips: [CGPoint] = []
    var faceContour: [CGPoint] = []

    var boundingBox = CGRect.zero

    func clear() {
        leftEye = []
        rightEye = []
        leftEyebrow = []
        rightEyebrow = []
        nose = []
        outerLips = []
        innerLips = []
        faceContour = []

        boundingBox = .zero

        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.saveGState()

        defer {
            context.restoreGState()
        }

        context.addRect(boundingBox)
        UIColor.red.setStroke()
        context.strokePath()

    }
}
