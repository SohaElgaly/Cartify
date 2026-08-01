//
//  HomeNavigationBar.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct HomeNavigationBar: View {
    let username: String
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment:.leading,spacing: 4) {
                Text("Welcome")
                    .font(.custom("Poppins-Regular", size: 24))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                
                Text(username)
                    .foregroundStyle(Color.black)
                    .font(.custom("Poppins-Regular", size: 24))
                    .fontWeight(.semibold)
                
            }
            Spacer()
            Button {
            } label: {
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.gray.opacity(0.12))
                .clipShape(Circle())
        }
        }.padding()
    }
}

#Preview {
    HomeNavigationBar(username: "Soha")
}
