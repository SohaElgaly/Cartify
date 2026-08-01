//
//  HomeRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/07/2026.
//

import Foundation

protocol HomeRepository {
  func fetchHome() async throws -> HomeResponse
}
