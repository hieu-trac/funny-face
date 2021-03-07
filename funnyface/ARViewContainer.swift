//
//  ARViewContainer.swift
//  funnyface
//
//  Created by Hieu C Trac on 3/7/21.
//

import ARKit
import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var currentProp: Prop
    @Binding var shouldTakeSnapShot: Bool

    class Coordinator: NSObject, ARSessionDelegate {
        var arViewContainer: ARViewContainer
        var arView: ARView!
        var isSparking: Bool = false
        var isWiggling: Bool = false
        
        init(_ container: ARViewContainer) {
            self.arViewContainer = container
            super.init()
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
            arViewContainer.shouldTakeSnapShot = false
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else { return }
            eyeballLook(at: faceAnchor.lookAtPoint)
            animateMustache(faceAnchor: faceAnchor)
            animateRobot(faceAnchor: faceAnchor)
        }
        
        private func makeRedLight() -> PointLight {
            let redLight = PointLight()
            redLight.light.color = .red
            redLight.light.intensity = 100_000
            return redLight
        }
        
        private func eyeballLook(at point: simd_float3) {
            guard let eyeball = arView.scene.findEntity(named: "Eyeball") else { return }
            
            eyeball.look(at: point, from: eyeball.position, upVector: SIMD3<Float>(0, 1, -1), relativeTo: eyeball.parent)
        }
        
        private func animateRobot(faceAnchor: ARFaceAnchor) {
            guard let robot = arView.scene.anchors.first(where: { $0 is Experience.Robot }) as? Experience.Robot else { return }
            
            let blendShapes = faceAnchor.blendShapes
            guard let jawOpen = blendShapes[.jawOpen]?.floatValue, let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue, let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
                  let browInnerUp = blendShapes[.browInnerUp]?.floatValue, let browLeft = blendShapes[.browDownLeft]?.floatValue, let browRight = blendShapes[.browDownRight]?.floatValue else {return }
            
            if !isSparking && jawOpen > 0.75 && browInnerUp < 0.4 {
                isSparking = true
                
                let lightLeft = makeRedLight()
                let lightRight = makeRedLight()
                
                robot.eyeL?.addChild(lightLeft)
                robot.eyeR?.addChild(lightRight)
                
                robot.notifications.spark.post()
                
                robot.actions.sparkDidEnd.onAction = { _ in
                    self.isSparking = false
                    lightLeft.removeFromParent()
                    lightRight.removeFromParent()
                }
            }
            
            robot.eyeLidL?.orientation = simd_mul(
                simd_quatf(angle: (-120.0 + (90.0 * eyeBlinkLeft)).radians, axis: [1, 0, 0]),
                simd_quatf(angle: ((90.0 * browLeft) - (30.0 * browInnerUp)).radians, axis: [0, 0, 1] )
            )

            robot.eyeLidR?.orientation = simd_mul(
                simd_quatf(angle: (-120.0 + (90.0 * eyeBlinkRight)).radians, axis: [1, 0, 0]),
                simd_quatf(angle: ((-90.0 * browRight) - (-30.0 * browInnerUp)).radians, axis: [0, 0, 1] )
            )
            
            robot.jaw?.orientation = simd_quatf(
                angle: (-100 + (60 * jawOpen)).radians, axis: [1, 0, 0]
            )
        }
        
        private func animateMustache(faceAnchor: ARFaceAnchor) {
            guard let mustache = arView.scene.anchors.first(where: { $0 is Experience.Mustache }) as? Experience.Mustache else { return }
            
            let blendShapes = faceAnchor.blendShapes
            
            guard let smiling = blendShapes[.mouthSmileLeft]?.floatValue else { return }
            
            if !isWiggling && smiling > 0.6 {
                isWiggling = true
                
                mustache.notifications.wiggle.post()
                
                mustache.actions.wiggleDidEnd.onAction = { _ in
                    self.isWiggling = false
                }
            }
        }
    }
            
    func makeCoordinator() -> ARViewContainer.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.scene.anchors.removeAll()
        
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        switch currentProp {
        case .fancyHat:
            uiView.scene.addAnchor(try! Experience.loadFancyHat())
        case .speechBubble:
            uiView.scene.addAnchor(try! Experience.loadSpeechBubble())
        case .eyeball:
            uiView.scene.addAnchor(try! Experience.loadEyeBall())
        case .glasses:
            uiView.scene.addAnchor(try! Experience.loadGlasses())
        case .food:
            uiView.scene.addAnchor(try! Experience.loadFood())
        case .mustache:
            uiView.scene.addAnchor(try! Experience.loadMustache())
        case .robot:
            uiView.scene.addAnchor(try! Experience.loadRobot())
        case .combo1:
            uiView.scene.addAnchor(try! Experience.loadFancyHat())
            uiView.scene.addAnchor(try! Experience.loadGlasses())
            uiView.scene.addAnchor(try! Experience.loadMustache())
        case .combo2:
            uiView.scene.addAnchor(try! Experience.loadRobot())
            uiView.scene.addAnchor(try! Experience.loadFood())
        }
        
        if (shouldTakeSnapShot) {
            uiView.snapshot(saveToHDR: false) { (image) in
                if let pngImage = image?.pngData(), let compressedImage = UIImage(data: pngImage) {
                    UIImageWriteToSavedPhotosAlbum(compressedImage, context.coordinator, #selector(Coordinator.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
}
struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARViewContainer(currentProp: .constant(.robot), shouldTakeSnapShot: .constant(false))
    }
}
