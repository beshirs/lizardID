//
//  CameraView.swift
//  frontend
//
//  Created by saidb on 6/20/25.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var camera: CameraHandeler
    private let label = Text("Frame")

    var body: some View {
        GeometryReader { proxy in
            if let cg = camera.frame {
                Image(cg, scale: 1.0, orientation: .up, label: label)
                  .resizable().scaledToFill()
                  .frame(width: proxy.size.width, height: proxy.size.height)
                  .clipped()
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
        .onAppear {
            camera.checkPermission()
        }
    }
}
