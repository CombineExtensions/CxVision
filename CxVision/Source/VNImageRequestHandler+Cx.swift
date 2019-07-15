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
  ///
  /// The number of `VNRecognizedTextObservation`s is closely related to the number of lines of text contained in the image.
  func publisher<A: VNRequest, B: VNObservation>(with configuration: Configuration<A, B>) -> AnyPublisher<[B], Error> {
    var requests = [VNRequest]()
    
    let visionFuture = Future<[B], Error> { resultFn in
      var visionRequest = A { (request, error) in
        if let error = error { return resultFn(.failure(error)) }
        
        guard let results = request.results as? [B] else {
          return resultFn(.failure(VisionError.unexpectedResultType))
        }
        
        return resultFn(.success(results))
      }
      
      configuration.configure(&visionRequest)
      requests.append(visionRequest)
    }
    
    let performPublisher = Publishers.Once<(), Error>(Result { try self.perform(requests) })
    
    return performPublisher
      .combineLatest(visionFuture)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
  
  func publisher<A: VNRequest>(with configurations: [Configuration<A, VNObservation>]) -> AnyPublisher<[VNObservation], Error> {
    var requests = [VNRequest]()
    
    let futures = Publishers.MergeMany<Future<[VNObservation], Error>>(
      configurations.map { configuration -> Future<[VNObservation], Error> in
        Future { resultFn in
          var request = configuration.type.init { request, error in
            if let error = error { return resultFn(.failure(error)) }
            
            guard let results = request.results as? [VNObservation] else { return resultFn(.failure(VisionError.unexpectedResultType)) }
            
            return resultFn(.success(results))
          }
          
          configuration.configure(&request)
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

  func multipleRequestPublisher(_ requestTypes: [(VNImageBasedRequest.Type)]) -> AnyPublisher<[VNObservation], Error> {
    var requests = [VNImageBasedRequest]()
    
    let futures = Publishers.MergeMany<Future<[VNObservation], Error>>(
      requestTypes.map { requestType -> Future<[VNObservation], Error> in
        Future { resultFn in
          let request = requestType.init { request, error in
            if let error = error { return resultFn(.failure(error)) }
            
            guard let results = request.results as? [VNObservation] else {
              return resultFn(.failure(VisionError.unexpectedResultType))
            }
            
            return resultFn(.success(results))
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
