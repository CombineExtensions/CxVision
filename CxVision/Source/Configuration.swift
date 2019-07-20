//
//  Configuration.swift
//  CxVision
//
//  Created by Steven Sherry on 7/14/19.
//  Copyright © 2019 Steven Sherry. All rights reserved.
//

import Vision
import CoreImage

/// A struct for holding onto a configuration function to be applied to a `VNRequest`
///
/// The VNObservation type parameter is used for typecasting in the VNImageRequestHandler extension method `publisher(for:)`
/// to return a publisher that emits the expected VNObservation subclass. If you prefer to typecast at the callsite, a `SimpleConfiguration<A: VNRequest>`
/// typealias is provided
public struct Configuration<Request: VNRequest, Observation: VNObservation> {
  let configure: (inout Request) -> ()
  
  /// Configuration initializer
  /// - Parameter configuration: The configuration function to apply the to VNRequest.
  ///
  /// *An example Configuration initialization:*
  /// ```
  /// let recognizeTextConfig = Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { request in
  ///   request.minimumTextHeight = 10.0
  ///   request.recognitionLevel = .fast
  ///   request.regionOfInterest = CGRect(origin: .zero, size: CGSize(width: 0.50, height: 0.50)
  ///   request.prefersBackgroundProcessing = true
  /// }
  /// ```
  public init(_ configuration: @escaping (inout Request) -> ()) {
    configure = configuration
  }
}

public typealias SimpleConfiguration<Request: VNRequest> = Configuration<Request, VNObservation>

public extension Configuration where Request == VNCoreMLRequest {
  init(model: VNCoreMLModel, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(model: model, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

public extension Configuration where Request == VNTrackRectangleRequest {
  init(rectangleObservation: VNRectangleObservation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(rectangleObservation: rectangleObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

public extension Configuration where Request == VNTrackObjectRequest {
  init(detectedObjectObservation: VNDetectedObjectObservation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(detectedObjectObservation: detectedObjectObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

public extension Configuration where Request: VNTargetedImageRequest {
  init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCGImage: targetedCGImage, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCGImage: targetedCGImage, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCIImage: targetedCIImage, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCIImage: targetedCIImage, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCVPixelBuffer: targetedCVPixelBuffer, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedCVPixelBuffer: targetedCVPixelBuffer, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageData: Data, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedImageData: targetedImageData, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageData: Data, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedImageData: targetedImageData, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedImageURL: targetedImageURL, orientation: orientation, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
  
  init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout Request) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = Request(targetedImageURL: targetedImageURL, options: options, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}
