//
//  CameraHandeler.swift
//  frontend
//
//  Created by saidb on 6/20/25.
//

import AVFoundation
import CoreImage

class CameraHandeler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    override init() {
        super.init()
        checkPermission()
    }
    
    // Checks if the user has allowed for the camera to be used
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            startRunningSession()
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    // Requests the user to allow for the camera to be used
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if granted {
                    self.startRunningSession()
                }
            }
        }
    }
    
    // Configure and start the capture session
    private func startRunningSession() {
        sessionQueue.async { [unowned self] in
            setUpCaptureSession()
            captureSession.startRunning()
        }
    }

    /*
     Begins the capture session.
     
     Checks if permission has been granted to use the camera.
     Takes the camera input if the permission is granted.
     Checks if the camera input can be used then uses it.
     */
    func setUpCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()

        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
        ) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "sampleBufferQueue")
        )
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        // Ensure the video is right-side-up
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
}

extension CameraHandeler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(
        sampleBuffer: CMSampleBuffer
    ) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
}
