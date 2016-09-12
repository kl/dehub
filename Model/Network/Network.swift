//
//  Network.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Gloss

protocol P_Network {
  func setUsername(username: String, password: String)
  func tryLogin(username: String, password: String) -> Observable<(NSData, NSHTTPURLResponse)>
  func getGists() -> Observable<[JSON]>
}

class Network : P_Network {
  
  private let urlSession: NSURLSession
  private let requests: RequestHelper
  
  init(session: NSURLSession, requestHelper: RequestHelper) {
    urlSession = session
    requests = requestHelper
  }
  
  func setUsername(username: String, password: String) {
    requests.setUsername(username, password: password)
  }
  
  func tryLogin(username: String, password: String) -> Observable<(NSData, NSHTTPURLResponse)> {
    return urlSession.rx_response(
      requests.makeLoginRequest(username, password: password)
    )
    .observeOn(MainScheduler.instance)
  }

  func getGists() -> Observable<[JSON]> {
    return urlSession.rx_JSON_cast(requests.GET("gists"))
  }
}

extension NSURLSession {
  
  func rx_JSON_cast<T>(req: NSURLRequest) -> Observable<T> {
    return rx_JSON(req).map() { json in
      if let json = json as? T {
        return json
      } else {
        throw NSURLError.CannotDecodeContentData
      }
      }
      .observeOn(MainScheduler.instance)
  }
}