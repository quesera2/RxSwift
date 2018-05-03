//
//  RxSearchResultsUpdatingProxy.swift
//  RxCocoa
//
//  Created by glayash on 2018/05/02.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

@available(iOS 8.0, tvOS 9.0, *)
open class RxSearchResultsUpdatingProxy
    : DelegateProxy<UISearchController, UISearchResultsUpdating>
    , DelegateProxyType
    , UISearchResultsUpdating {
    
    /// Typed parent object.
    public weak private(set) var searchController: UISearchController?
    
    /// - parameter searchController: Parent object for delegate proxy.
    init(searchController: UISearchController) {
        self.searchController = searchController
        super.init(parentObject: searchController, delegateProxy: RxSearchResultsUpdatingProxy.self)
    }
    
    // Register known implementations
    public class func registerKnownImplementations() {
        self.register { RxSearchResultsUpdatingProxy(searchController: $0) }
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegate(for object: UISearchController) -> UISearchResultsUpdating? {
        return object.searchResultsUpdater
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: UISearchResultsUpdating?, to object: UISearchController) {
        object.searchResultsUpdater = delegate
    }
    
    fileprivate var _didUpdateSearchResultsSubject: PublishSubject<UISearchController>?
    
    /// Optimized version used for observing search results changes.
    internal var didUpdateSearchResultSubject: PublishSubject<UISearchController> {
        if let subject = _didUpdateSearchResultsSubject {
            return subject
        }
        
        let subject = PublishSubject<UISearchController>()
        _didUpdateSearchResultsSubject = subject
        
        return subject
    }
    
    deinit {
        if let subject = _didUpdateSearchResultsSubject {
            subject.on(.completed)
        }
    }
    
    // MARK: delegate
    
    public func updateSearchResults(for searchController: UISearchController) {
        _forwardToDelegate?.updateSearchResults?(for: searchController)
        didUpdateSearchResultSubject.on(.next(searchController))
    }
}

#endif
