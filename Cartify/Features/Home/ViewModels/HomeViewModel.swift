//
//  HomeViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/07/2026.
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var featuredProducts: [Product] = []
    private(set) var newArrivals: [Product] = []
    private(set) var categories: [Category] = []
    private(set) var banners: [Banner] = []
    private let repository: HomeRepository
    var searchText = ""
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    
    func loadHome() async {
        do {
            let home = try await repository.fetchHome()
            banners = home.banners
            categories = home.categories 
            newArrivals = home.newArrivals
            featuredProducts = home.featuredProducts
            print(home)
            } catch {
                print(error)
            }
    }
}
