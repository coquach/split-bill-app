//
//  HomeView.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public struct HomeView: View {

    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 20) {

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
        .padding()
    }
}
