//
//  AnyObservableObject.swift
//  AnyObservableObject
//
//  Created by marty-suzuki on 2022/04/03.
//  Copyright © 2022 marty-suzuki. All rights reserved.
//

import Combine

public protocol ObservableObjectType: AnyObject {
    associatedtype Input: InputType
    associatedtype Binding: BindingType
    associatedtype Output: OutputType
    var input: InputWrapper<Input> { get }
    var binding: BindingWrapper<Binding> { get }
    var output: OutputWrapper<Output> { get }
}

extension ObservableObjectType {
    public func eraseToAnyObservableObject() -> AnyObservableObject<Input, Binding, Output> {
        AnyObservableObject(self)
    }
}

public final class AnyObservableObject<
    Input: InputType,
    Binding: BindingType,
    Output: OutputType
>: ObservableObjectType, ObservableObject {
    public let input: InputWrapper<Input>
    public let output: OutputWrapper<Output>
    
    @Bindable
    public var binding: BindingWrapper<Binding>
    
    public var objectWillChange: AnyPublisher<Void, Never> {
        let p1 = binding.objectWillChange.map { _ in }
        let p2 = output.objectWillChange.map { _ in }
        return p1.merge(with: p2).eraseToAnyPublisher()
    }
    
    private let observableObject: AnyObject
    
    public init<Object: ObservableObjectType>(
        _ observableObject: Object
    ) where Input == Object.Input, Binding == Object.Binding, Output == Object.Output {
        self.input = observableObject.input
        self._binding = Bindable(wrappedValue: observableObject.binding)
        self.output = observableObject.output
        self.observableObject = observableObject
    }
}
