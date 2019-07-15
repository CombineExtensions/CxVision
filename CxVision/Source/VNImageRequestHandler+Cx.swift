//
//  VNImageRequestHandler+Cx.swift
//  CxVision
//
//  Created by Steven Sherry on 7/6/19.
//  Copyright © 2019 Steven Sherry. All rights reserved.
//

import Vision
import Combine

enum VisionError: Error {
  case unexpectedResultType
}

public extension VNImageRequestHandler {
  /// Creates a publisher based on the provided Configuration
  /// - Parameter configuration: Configuration<A: VNRequest, B: VNObservation>. Default implementation provided in cases where the publisher is assigned directly.
  func publisher<Request: VNRequest, Observation: VNObservation>(for configuration: Configuration<Request, Observation>) -> AnyPublisher<[Observation], Error> {
    var requests = [VNRequest]()
    
    let visionFuture = Future<[Observation], Error> { promise in
      var visionRequest = Request { (request, error) in
        if let error = error { return promise(.failure(error)) }
        
        guard let results = request.results as? [Observation] else {
          return promise(.failure(VisionError.unexpectedResultType))
        }
        
        return promise(.success(results))
      }
      
      configuration.configure(&visionRequest)
      requests.append(visionRequest)
    }
    
    let performPublisher = Future { resultFn in resultFn(Result { try self.perform(requests) }) }
    
    return performPublisher
      .combineLatest(visionFuture)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
  
  /// Creates a publisher that performs a collection of Vision operations.
  /// - Parameter requestTypes: The types of Vision requests to perform
  ///
  /// This is the only way to perform a batch of operations on the same request handler, which unfortunately does not support
  /// customization.
  func publisher(for requestTypes: [VNImageBasedRequest.Type]) -> AnyPublisher<[VNObservation], Error> {
    var requests = [VNImageBasedRequest]()
    
    let futures = Publishers.MergeMany<Future<[VNObservation], Error>>(
      requestTypes.map { requestType -> Future<[VNObservation], Error> in
        Future { promise in
          let request = requestType.init { request, error in
            if let error = error { return promise(.failure(error)) }
            
            guard let results = request.results as? [VNObservation] else {
              return promise(.failure(VisionError.unexpectedResultType))
            }
            
            return promise(.success(results))
          }
          requests.append(request)
        }
      }
    )
      
    let performPublisher = Publishers.Once<(), Error>(Result { try self.perform(requests) })
    
    return performPublisher
      .combineLatest(futures)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
}
