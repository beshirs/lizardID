//
//  ContentView.swift
//  frontend
//
//  Created by saidb on 6/18/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    /// @StateObject private var camera = CameraHandeler()
    @State private var showCameraUI  = false
    @State private var imageSelected = false
    @State private var prediction : (seen: Bool, id: String?, score: Float) = (false, nil, 0)
    @State private var showPredictionAlert = false
    @StateObject var model = ModelHandler()!
    
    var body: some View {
        if (showCameraUI) {
            CameraView(cameraImage: camera.frame)
                .ignoresSafeArea(.all)
        } else {
            ZStack {
                //Selected image from either taking a picture or choosing a picture
                Image(uiImage: selectedImage ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .clipped()
                
                VStack {
                    //Title
                    Text("Lizard Identifier")
                        .font(
                            .largeTitle
                                .bold()
                        )
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    //Bottom icons
                    if (imageSelected) {
                        Button(action: {
                            Task {
                                guard let img = selectedImage else { return }
                                
                                if NetworkMonitor.shared.isConnected {
                                    do {
                                        let pred = try await NetworkManager.shared.predict(image: img)
                                        prediction = (seen: pred.seen, id: pred.id, score: Float(pred.score))
                                        showPredictionAlert = true
                                    } catch {
                                        // handle network error
                                    }
                                } else if let offlinePred = model.predict(uiImage: img) {
                                    prediction = offlinePred
                                    showPredictionAlert = true
                                } else {
                                    // show error for offline failure
                                }
                            }
                            //Create model for sending images to the backend
                        }, label: {
                            Text("Identify Lizard")
                        })
                        .padding(.bottom, 20)
                    }
                    
                    HStack {
                        //Left icon for selecting an image from the camera roll
                        //(Will implement selecting multiple images if necessary)
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .imageScale(.large)
                                .font(.system(size: 50))
                                .foregroundStyle(.tint)
                        }
                        
                        Spacer()
                        
                        //Right icon for taking an image
                        //(Will implement taking multiple pictures if necessary)
                        Button(action: {
                            showCameraUI.toggle()
                        }, label: {
                            Image(systemName: "camera.fill")
                                .imageScale(.large)
                                .font(.system(size: 50))
                                .foregroundStyle(.tint)
                        })
                    }
                }
                .padding()
                .onChange(of: photosPickerItem) { _, _ in
                    Task {
                        if let photosPickerItem,
                           let photoData = try? await photosPickerItem.loadTransferable(type: Data.self),
                           let uiImg = UIImage(data: photoData) {
                            selectedImage = uiImg
                            imageSelected = true
                        }
                    }
                }
            }
            .alert("Lizard Prediction", isPresented: $showPredictionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let p = prediction {
                    Text("""
                        Seen before: \(p.seen ? "Yes" : "No")
                        ID: \(p.id ?? "–")
                        Score: \(String(format: "%.2f", p.score))
                        """)
                } else {
                    Text("Failed to compute embedding.")
                }
            }
        }
    }
    
    func loadData() async {
        //Change url later to get data from the database
        guard let url = Bundle.main.url(forResource: "lizard_data", withExtension: "json") else {
            print("Could not get data")
            return
        }
    }
}

struct Results: Codable {
    var results: String
}

struct lizarData: Codable {
    var lizardNumber: Int
    //add more data later
}

#Preview {
    ContentView()
}
