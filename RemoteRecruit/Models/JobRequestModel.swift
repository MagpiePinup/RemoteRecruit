//
//  JobRequestModel.swift
//  RemoteRecruit
//
//  Created by naveenkumar01 on 07/06/26.
//

import Foundation

struct JobRequestModel: RequestProtocol {
    typealias Response = JobsResponse
    
    let url = "https://himalayas.app/api/jobs"
    let httpMethod = "GET"
}
