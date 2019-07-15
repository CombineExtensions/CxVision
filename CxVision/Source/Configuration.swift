//
//  Configuration.swift
//  CxVision
//
//  Created by Steven Sherry on 7/14/19.
//  Copyright © 2019 Steven Sherry. All rights reserved.
//

import Vision

public struct Configuration<A: VNRequest, B: VNObservation> {
  let type = A.self
  let configure: (inout A) -> ()
  
  public init(_ configuration: @escaping (inout A) -> ()) {
    configure = configuration
  }
}

public extension Configuration where A == VNCoreMLRequest {
  init(model: VNCoreMLModel, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(model: model, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

public extension Configuration where A == VNTrackRectangleRequest {
  init(rectangleObservation: VNRectangleObservation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(rectangleObservation: rectangleObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

public extension Configuration where A == VNTrackObjectRequest {
  init(detectedObjectObservation: VNDetectedObjectObservation, _ configuration: @escaping (inout A) -> ()) {
    configure = { request in
      let completionHandler = request.completionHandler
      request = A(detectedObjectObservation: detectedObjectObservation, completionHandler: completionHandler)
      configuration(&request)
    }
  }
}

// TODO: - VNTargetedImageRequest extension, there's a lot there but it covers several types of image requests
