//
//  ProcessingView.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
//

import SwiftUI

struct ProcessingView: View {
    @StateObject private var viewModel = ProcessingViewModel()
    @State private var jobId: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Processing Animation
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(TonaColors.mediumGray, lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                TonaColors.primaryBlue,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                        
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(.tonaTitle2())
                            .foregroundColor(TonaColors.primaryBlue)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Processing Images")
                            .font(.tonaTitle2())
                            .foregroundColor(TonaColors.primaryDarkBlue)
                        
                        Text(viewModel.currentStep)
                            .font(.tonaBody())
                            .foregroundColor(TonaColors.darkGray)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.tonaCaption())
                        .foregroundColor(TonaColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Cancel Button
                TonaButton("Cancel", style: .secondary, isEnabled: viewModel.isProcessing) {
                    viewModel.cancelProcessing()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, TonaSpacing.screenMargins)
            .background(TonaColors.lightGray)
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .navigateToProcessing)) { notification in
                if let jobId = notification.object as? String {
                    self.jobId = jobId
                    viewModel.startProcessing(jobId: jobId)
                }
            }
        }
    }
}

#Preview {
    ProcessingView()
}
