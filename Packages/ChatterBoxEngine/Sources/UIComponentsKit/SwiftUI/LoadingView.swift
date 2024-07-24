//
//  LoadingView.swift
//
//
//  Created by Dmytro Vorko on 24/07/2024.
//

import SwiftUI

public struct LoadingView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
        }
        .ignoresSafeArea(.all)
    }
}

