//
//  ImageConfirmationView.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import SwiftUI
import UIComponentsKit

struct ImageConfirmationView: View {
    @ObservedObject private var viewModel: ImageConfirmationViewModel
    
    init(viewModel: ImageConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.images.count == 1 ? Color.clear : Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        self.viewModel.didTapCancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .padding()
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    Spacer()
                    
                    Button(action: {
                        self.viewModel.didTapConfirm()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .imageScale(.large)
                            .padding()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .blur(radius: viewModel.showLoader ? 3 : 0)
            
            if viewModel.showLoader {
                LoadingView()
            }
        }
        .navigationTitle("Confirm Images")
        .navigationBarHidden(true)
    }
}
