//
//  HomeView.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    init(viewModel: HomeViewModel) {
           _viewModel = State(initialValue: viewModel)
       }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HomeNavigationBar(username: "Soha")
            }
            .padding()
        }
        Text("Products:\(viewModel.products.count)")
            .task {
               await viewModel.loadProducts()
            }
    }
}
#Preview {
    HomeView(viewModel: AppContainer().makeHomeViewModel())
}
