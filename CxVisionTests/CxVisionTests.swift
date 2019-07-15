//
//  CxVisionTests.swift
//  CxVisionTests
//
//  Created by Steven Sherry on 7/6/19.
//  Copyright © 2019 Steven Sherry. All rights reserved.
//

import XCTest
import Vision
import CxVision

class CxVisionTests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testRequestHandler_publishesObservations_whenSubscribed() {
    let expectation = XCTestExpectation(description: "ObservationExpectation")
    _ = VNImageRequestHandler(data: getImage(named: "image_sample.jpg").pngData()!, options: [:])
      .publisher(with: Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { _ in })
      .sink { _ in
        expectation.fulfill()
      }

    wait(for: [expectation], timeout: 10)
  }
  
  func testRequestHandler_hasEqualNumberOfResults_asLinesOfTextInImage() {
    let oneLine = XCTestExpectation(description: "One line")
    let elevenLines = XCTestExpectation(description: "Eleven lines")
    _ = VNImageRequestHandler(data: getImage(named: "image_sample.jpg").pngData()!, options: [:])
      .publisher(with: Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { _ in })
      .sink { observations in
        XCTAssertEqual(observations.count, 1)
        oneLine.fulfill()
      }
    
    _ = VNImageRequestHandler(data: getImage(named: "Lenore3.png").pngData()!, options: [:])
      .publisher(with: Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { _ in })
      .sink { observations in
        XCTAssertEqual(observations.count, 11)
        elevenLines.fulfill()
      }
    
    wait(for: [oneLine, elevenLines], timeout: 10)
  }
  
  func testRequestHandlerObservationResult_contains1234567890_whenImageHasThatText() {
    let expectation = XCTestExpectation(description: "ObservationExpectation")
    _ = VNImageRequestHandler(data: getImage(named: "image_sample.jpg").pngData()!, options: [:])
      .publisher(with: Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { _ in })
      .sink { observations in
        XCTAssertEqual(observations.first!.topCandidates(1).first!.string.trimmingCharacters(in: .whitespacesAndNewlines), "1234567890")
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 10)
  }
  
  func testMultipleRequestPublisher_emitsMultipleValues() {
    let expectation = XCTestExpectation(description: "MultipleObservationsExpectation")
   
    _ = VNImageRequestHandler(data: getImage(named: "cardImage.png").pngData()!, options: [:])
      .multipleRequestPublisher([VNDetectRectanglesRequest.self, VNDetectBarcodesRequest.self, VNDetectTextRectanglesRequest.self, VNRecognizeTextRequest.self])
      .count()
      .assertNoFailure()
      .sink { int in
        XCTAssertEqual(int, 4)
        expectation.fulfill()
      }
    
    wait(for: [expectation], timeout: 20)
  }
}

extension XCTestCase {
  var bundle: Bundle {
    return Bundle(for: self.classForCoder)
  }
  
  func getImage(named name: String) -> UIImage {
    guard let image = UIImage(
      named: name,
      in: bundle,
      compatibleWith: nil
      ) else {
        fatalError()
    }
    
    return image
  }
}
