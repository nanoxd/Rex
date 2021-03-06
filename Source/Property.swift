//
//  Property.swift
//  Rex
//
//  Created by Neil Pankey on 5/29/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import ReactiveCocoa

/// A property that tracks a signals most recent value.
public struct SignalProperty<T>: PropertyType {
    private let property: MutableProperty<T>

    /// Current value of the property.
    public var value: T {
        return property.value
    }

    /// Sends the current `value` and any changes.
    public var producer: SignalProducer<T, NoError> {
        return property.producer
    }

    /// Creates a new property bound to `signal`.
    public init(_ value: T, _ signal: Signal<T, NoError>) {
        property = MutableProperty(value)
        property <~ signal
    }

    /// Creates a new property bound to `producer`.
    public init(_ value: T, _ producer: SignalProducer<T, NoError>) {
        property = MutableProperty(value)
        property <~ producer
    }
}

/// Creates a new property bound to `signal` starting with `initialValue`.
public func propertyOf<T>(initialValue: T)(signal: Signal<T, NoError>) -> PropertyOf<T> {
    return PropertyOf(SignalProperty(initialValue, signal))
}

/// Creates a new property bound to `producer` starting with `initialValue`.
public func propertyOf<T>(initialValue: T)(producer: SignalProducer<T, NoError>) -> PropertyOf<T> {
    return PropertyOf(SignalProperty(initialValue, producer))
}

/// Wraps `sink` in a property bound to `signal`. Values sent on `signal` are `put` into
/// the `sink` to update it.
public func propertySink<S: SinkType>(sink: S)(signal: Signal<S.Element, NoError>) -> PropertyOf<S> {
    return signal |> put(sink) |> propertyOf(sink)
}

/// Wraps `sink` in a property bound to `producer`. Values sent on `producer` are `put` into
/// the `sink` to update it.
public func propertySink<S: SinkType>(sink: S)(producer: SignalProducer<S.Element, NoError>) -> PropertyOf<S> {
    return producer |> put(sink) |> propertyOf(sink)
}

private func put<S: SinkType, E>(sink: S)(signal: Signal<S.Element, E>) -> Signal<S, E> {
    return signal
        |> scan(sink) { (var value, change) in
            value.put(change)
            return value
        }
}
