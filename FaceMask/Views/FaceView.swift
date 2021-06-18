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
        
        // 1
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        // 2
        context.saveGState()

        // 3
        defer {
            context.restoreGState()
        }

        // 4
        context.addRect(boundingBox)

        // 5
        UIColor.red.setStroke()

        // 6
        context.strokePath()

    }

}
