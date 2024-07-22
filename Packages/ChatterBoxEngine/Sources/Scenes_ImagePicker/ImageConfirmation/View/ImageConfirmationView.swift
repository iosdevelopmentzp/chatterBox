//
//  ImageConfirmationView.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import SwiftUI

struct ImageConfirmationView: View {
    @ObservedObject private var viewModel: ImageConfirmationViewModel
    
    init(viewModel: ImageConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
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
                    // TODO: - handle cancel button
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())

                Spacer()
                
                Button(action: {
                    // Implement send action
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
        .navigationTitle("Confirm Images")
        .navigationBarHidden(true)
    }
}

