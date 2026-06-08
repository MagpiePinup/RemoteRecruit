//
//  NetworkService.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import Foundation

protocol NertworkService {
    func fetchData<R: RequestProtocol>(input: R) async throws -> R.Response
}

struct RequestHeader {
    static let contentType = "Content-type"
    static let authorization = "Authorization"
}

final class NertworkServiceImp: NertworkService {
    func fetchData<R>(input: R) async throws -> R.Response where R : RequestProtocol {
        guard let url = URL(string: input.url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = input.httpMethod
        request.setValue("Application/json", forHTTPHeaderField: RequestHeader.contentType)
        request.setValue("Token", forHTTPHeaderField: RequestHeader.authorization)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let resp = response as? HTTPURLResponse, (200...299).contains(resp.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}
