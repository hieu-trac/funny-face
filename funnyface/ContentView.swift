//
//  ContentView.swift
//  funnyface
//
//  Created by Hieu C Trac on 3/6/21.
//

import ARKit
import SwiftUI
import RealityKit

struct ContentView : View {
    
    @State var currentProp: Prop = .glasses
    @State var shouldTakeSnapShot: Bool = false
    
    var body: some View {        
        ZStack(alignment: .bottom) {
            ARViewContainer(currentProp: $currentProp, shouldTakeSnapShot: $shouldTakeSnapShot).edgesIgnoringSafeArea(.all)
            PropChooser(currentProp: $currentProp, shouldTakeSnapShot: $shouldTakeSnapShot)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var currentProp: Prop
    @Binding var shouldTakeSnapShot: Bool

    class Coordinator: NSObject, ARSessionDelegate {
        var arViewContainer: ARViewContainer
        var arView: ARView!
        
        init(_ arViewContainer: ARViewContainer) {
            self.arViewContainer = arViewContainer
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
            arViewContainer.shouldTakeSnapShot = false
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else { return }
            eyeballLook(at: faceAnchor.lookAtPoint)
        }
        
        private func eyeballLook(at point: simd_float3) {
            guard let eyeball = arView.scene.findEntity(named: "Eyeball") else { return }
            
            eyeball.look(at: point, from: eyeball.position, upVector: SIMD3<Float>(0, 1, -1), relativeTo: eyeball.parent)
        }
    }
            
    func makeCoordinator() -> ARViewContainer.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.arView = uiView
        uiView.scene.anchors.removeAll()
        
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        var anchor: RealityKit.HasAnchoring
        switch currentProp {
        case .fancyHat:
            anchor = try! Experience.loadFancyHat()
        case .speechBubble:
            anchor = try! Experience.loadSpeechBubble()
        case .eyeball:
            anchor = try! Experience.loadEyeBall()
        case .glasses:
            anchor = try! Experience.loadGlasses()
        case .food:
            anchor = try! Experience.loadFood()
        case .mustache:
            anchor = try! Experience.loadMustache()
        }
        
        uiView.scene.addAnchor(anchor)
        
        if (shouldTakeSnapShot) {
            uiView.snapshot(saveToHDR: false) { (image) in
                if let pngImage = image?.pngData(), let compressedImage = UIImage(data: pngImage) {
                    UIImageWriteToSavedPhotosAlbum(compressedImage, context.coordinator, #selector(Coordinator.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
