//
//  HomeView.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import SystemDesign

public struct HomeView: View {

    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xl
            ) {
                Text("Welcome")
                Text(viewModel.email)

                Button {
                    Task {
                        await viewModel.logout()
                    }
                } label: {
                    if viewModel.isLoggingOut {
                        ProgressView()
                    } else {
                        Text("Log out")
                    }
                }
                .disabled(viewModel.isLoggingOut)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, 120)
    }
}
