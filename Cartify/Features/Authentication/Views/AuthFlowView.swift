//
//  AuthFlowView.swift
//  Cartify
//
//  Created by Soha Elgaly on 09/09/2026.
//

import SwiftUI

struct AuthFlowView: View {
    @State private var authSession = AppContainer.shared.authSession
    @State private var path: [AuthRoute] = []
    var body: some View {
        Group {
            if authSession.state == .authenticated {
                HomeView(viewModel: AppContainer.shared.makeHomeViewModel())
            } else {
                NavigationStack(path: $path) {
                    LoginView(viewModel: AppContainer.shared.makeLoginViewModel(), onRegisterTapped: {path.append(.register)})
                        .navigationDestination(for: AuthRoute.self) { route in
                            switch route {
                            case .register:
                                RegisterView(
                                viewModel: AppContainer.shared.makeRegisterViewModel(),
                                onSignInTapped: { path.removeLast() })
                            case .login:
                                LoginView(viewModel: AppContainer.shared.makeLoginViewModel(), onRegisterTapped: {path.append(.register)})
                            }
                        }
                }
            }
        }
        .task {
             authSession.restoreSession()
        }
    }
}

#Preview {
    AuthFlowView()
}
