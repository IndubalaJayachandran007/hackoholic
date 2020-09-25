//
//  NetworkManager.swift
//  ShopyShopy
//
//  Created by Bhavana Gr on 25/09/20.
//  Copyright © 2020 Bhavana Gr. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias CompletionHandler = (ResultData) -> Void
typealias ApiServiceCompletionHandler<T> = (ApiServiceResult<T>) -> Void

enum ResultData {
    case success(_ jsonResponse: Any?)
    case failure(_ error: Any?)
}

enum ApiServiceResult<T> {
    case success(_ jsonResponse: T?)
    case failure(_ error: Any?)
}

enum ErrorType {
    case somethingWentWrong
    case internetError
    case other
}

protocol ProductProtocol {
    func fetchCategoryProducts(zone: Int, currentPage: Int, categoryId: String, filterParams: String?, completionHandler: @escaping ApiServiceCompletionHandler<ProductListResponse>)
    
    func fetchProductDetailSummary(forOrderParams params: [String:String], headers: [String:String], completion: @escaping ApiServiceCompletionHandler<ProductDetailsModel>)
    
    func fetchCrossCellingProdcuts(forOrderParams params: [String:String], headers: [String:String], completion:  @escaping ApiServiceCompletionHandler<CrossCellingProductModel>)
    
}

class NetworkManager: ProductProtocol {
    
    func fetchCategoryProducts(zone: Int, currentPage: Int, categoryId: String, filterParams: String?, completionHandler: @escaping ApiServiceCompletionHandler<ProductListResponse>) {
        
        let url = "https://swapi.dev/api/films"
        
        let parameters: [String: String] = [:]
        
        AF.request(url, parameters: parameters).validate().responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if let data = try? JSON(data: data) {
                        self.parseResponse(ResultData.success(data), responseType: ProductListResponse.self, completionHandler: completionHandler)
                    } else {
                        self.parseResponse(ResultData.success(nil), responseType: ProductListResponse.self, completionHandler: completionHandler)
                    }
                }
                
            case .failure:
                if (response.error as NSError?)?.code == NSURLErrorCancelled {
                    return
                }
            }
            
        }
        
    }
    
    func fetchProductDetailSummary(forOrderParams params: [String:String], headers: [String:String], completion: @escaping ApiServiceCompletionHandler<ProductDetailsModel>) {
        
        let url = ""
        
        let parameters: [String: String] = [:]
        
        AF.request(url, parameters: parameters).validate().responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if let data = try? JSON(data: data) {
                        self.parseResponse(ResultData.success(data), responseType: ProductDetailsModel.self, completionHandler: completion)
                    } else {
                        self.parseResponse(ResultData.success(nil), responseType: ProductDetailsModel.self, completionHandler: completion)
                    }
                }
                
            case .failure:
                if (response.error as NSError?)?.code == NSURLErrorCancelled {
                    return
                }
            }
            
        }
        
    }
    
    func fetchCrossCellingProdcuts(forOrderParams params: [String:String], headers: [String:String], completion: @escaping ApiServiceCompletionHandler<CrossCellingProductModel>) {
        let url = ""
        
        let parameters: [String: String] = [:]
        
        AF.request(url, parameters: parameters).validate().responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if let data = try? JSON(data: data) {
                        self.parseResponse(ResultData.success(data), responseType: CrossCellingProductModel.self, completionHandler: completion)
                    } else {
                        self.parseResponse(ResultData.success(nil), responseType: CrossCellingProductModel.self, completionHandler: completion)
                    }
                }
                
            case .failure:
                if (response.error as NSError?)?.code == NSURLErrorCancelled {
                    return
                }
            }
            
        }
        
    }
    
    
    
}

extension NetworkManager {
    func parseResponse<T: Decodable>(_ result: ResultData,
                                     responseType: T.Type,
                                     completionHandler: @escaping ApiServiceCompletionHandler<T>) {
        switch (result) {
        case .success(let response):
            guard let jsonResponse = response as? JSON else {
                completionHandler(ApiServiceResult.failure(ErrorType.somethingWentWrong))
                return
            }
            
            do {
                let parsedModels = try JSONDecoder().decode(responseType.self, from: jsonResponse.rawData())
                completionHandler(ApiServiceResult.success(parsedModels))
            } catch(let _) {
                completionHandler(ApiServiceResult.failure(ErrorType.somethingWentWrong))
            }
        case .failure(let error):
            completionHandler(ApiServiceResult.failure(error))
        }
    }
    
}
