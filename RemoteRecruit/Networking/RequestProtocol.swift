//
//  RequestProtocol.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

protocol RequestProtocol {
    associatedtype Response: Decodable
    
    var url: String { get }
    var httpMethod: String { get }
}
