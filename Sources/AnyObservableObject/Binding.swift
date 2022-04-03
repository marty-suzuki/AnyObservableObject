//
//  Binding.swift
//  AnyObservableObject
//
//  Created by marty-suzuki on 2022/04/03.
//  Copyright © 2022 marty-suzuki. All rights reserved.
//

import SwiftUI

public protocol BindingType: ObservableObject {}

extension BindingType {
    public func toWrapper() -> BindingWrapper<Self> {
        BindingWrapper(self)
    }
}

@dynamicMemberLookup
public final class BindingWrapper<T: BindingType>: ObservableObject {

    public var objectWillChange: T.ObjectWillChangePublisher {
        object.objectWillChange
    }
    
    fileprivate let object: T
    
    public init(_ object: T) {
        self.object = object
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        object[keyPath: keyPath]
    }
}

@propertyWrapper
public struct Bindable<T: BindingType> {
    
    public let wrappedValue: BindingWrapper<T>
    public var projectedValue: Wrapper {
        Wrapper(binding: wrappedValue)
    }

    public init(
        wrappedValue: BindingWrapper<T>
    ) {
        self.wrappedValue = wrappedValue
    }
}

extension Bindable {
    
    @dynamicMemberLookup
    public struct Wrapper {
        fileprivate let binding: BindingWrapper<T>
        
        public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>) -> Binding<Value> {
            return .init(
                get: { self.binding.object[keyPath: keyPath] },
                set: { self.binding.object[keyPath: keyPath] = $0 }
            )
        }
    }
}
