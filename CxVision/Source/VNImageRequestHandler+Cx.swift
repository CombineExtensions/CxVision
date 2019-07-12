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

/// A value representing the configuration variables available on `VNRequest`.
/// All members variables are made optional for convenience at the callsite. Any
/// parameters not assigned will fallback to the `VNRequest` defaults.
public struct VNRequestConfiguration {
  public var preferBackgroundProcessing: Bool? = nil
  public var usesCPUOnly: Bool? = nil
}

extension VNRequest {
  func configure(_ configuration: VNRequestConfiguration) {
    preferBackgroundProcessing = configuration.preferBackgroundProcessing ?? preferBackgroundProcessing
    usesCPUOnly = configuration.usesCPUOnly ?? usesCPUOnly
  }
}

/// A value representing the configuration variables available on `VNImageBasedRequest`
/// All members variables are made optional for convenience at the callsite. Any
/// parameters not assigned will fallback to the `VNImageBasedRequest` defaults.
public struct VNImageBasedRequestConfiguration {
  public var vnRequestConfiguration: VNRequestConfiguration? = nil
  public var regionOfInterest: CGRect? = nil
}

extension VNImageBasedRequest {
  func configure(_ configuration: VNImageBasedRequestConfiguration) {
    configure(configuration.vnRequestConfiguration ?? VNRequestConfiguration())
    regionOfInterest = configuration.regionOfInterest ?? regionOfInterest
  }
}

/// A value representing the configuration variables available on `VNRecognizeTextRequest`
/// All members variables are made optional for convenience at the callsite. Any
/// parameters not assigned will fallback to the `VNRecognizeTextRequest` defaults.
public struct VNRecognizeTextRequestConfiguration {
  public var vnImageBasedRequestConfiguration: VNImageBasedRequestConfiguration? = nil
  public var customWords: [String]? = nil
  public var minimumTextHeight: Float? = nil
  public var recognitionLevel: VNRequestTextRecognitionLevel? = nil
  public var recognitionLanugages: [String]? = nil
  public var usesLanguageCorrection: Bool? = nil
}

extension VNRecognizeTextRequest {
  func configure(_ configuration: VNRecognizeTextRequestConfiguration) {
    configure(configuration.vnImageBasedRequestConfiguration ?? VNImageBasedRequestConfiguration())
    customWords = configuration.customWords ?? customWords
    minimumTextHeight = configuration.minimumTextHeight ?? minimumTextHeight
    recognitionLevel = configuration.recognitionLevel ?? recognitionLevel
    recognitionLanguages = configuration.recognitionLanugages ?? recognitionLanguages
    usesLanguageCorrection = configuration.usesLanguageCorrection ?? usesLanguageCorrection
  }
}

public extension VNImageRequestHandler {
  /// Provides a publisher that receives optical character recognition results from the image provided to the `VNImageRequestHandler` initializer
  /// - Parameter configuration: An optional `VNRecognizeTextRequestConfiguration` for overriding any default `VNRecognizeTextRequest` values.
  ///
  /// The number of `VNRecognizedTextObservation`s is closely related to the number of lines of text contained in the image.
  func textRecognitionPublisher(with configuration: VNRecognizeTextRequestConfiguration? = nil) -> AnyPublisher<[VNRecognizedTextObservation], Error> {
    var requests = [VNRequest]()
    
    let recognizeTextFuture = Future<[VNRecognizedTextObservation], Error> { resultFn in
      let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
        if let error = error { return resultFn(.failure(error)) }
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
          return resultFn(.failure(VisionError.unexpectedResultType))
        }
        
        return resultFn(.success(results))
      }
  
      recognizeTextRequest.configure(configuration ?? VNRecognizeTextRequestConfiguration())
      requests.append(recognizeTextRequest)
    }
      
    let performPublisher = Publishers.Once<(), Error>(Result { try self.perform(requests) })
      
    return performPublisher
      .combineLatest(recognizeTextFuture)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }

  func multipleRequestPublisher(_ requestTypes: [VNRequest.Type]) -> AnyPublisher<[VNObservation], Error> {
    var requests = [VNRequest]()
    
    let manyFutures = Publishers.MergeMany<Future<[VNObservation], Error>>(
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
      .combineLatest(manyFutures)
      .map { _, results in results }
      .eraseToAnyPublisher()
  }
}
