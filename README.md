# AnyObservableObject

## Usage

```swift
// views

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                observableObject: SampleObservableObjectImpl().eraseToAnyObservableObject()
            )
        }
    }
}

struct ContentView: View {
    @ObservedObject var observableObject: AnySampleObservableObject
    
    var body: some View {
        Text(observableObject.output.text)
            .onTapGesture {
                observableObject.input.onTap()
            }
            .sheet(isPresented: observableObject.$binding.isPresenting) {
                Text("Hello, AnyObservableObject!")
            }
            .padding()
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView(
            observableObject: FakeObject().eraseToAnyObservableObject()
        )
    }
    
    private final class FakeObject: SampleObservableObject {
        let input = SampleInput().toWrapper()
        let binding = SampleBinging().toWrapper()
        let output: OutputWrapper<SampleOutput>
        
        init() {
            let output = SampleOutput()
            output.text = "Preview Title"
            self.output = output.toWrapper()
        }
    }
}
```

```swift
// definitions
final class SampleInput: InputType {
    let onTap = PassthroughSubject<Void, Never>()
}

final class SampleBinging: BindingType {
    @Published var isPresenting = false
}

final class SampleOutput: OutputType {
    @Published var text = "Sheet has not presented, yet\nPlease tap!"
}

protocol SampleObservableObject: ObservableObjectType {
    associatedtype Input = SampleInput
    associatedtype Binding = SampleBinging
    associatedtype Output = SampleOutput
}

typealias AnySampleObservableObject = AnyObservableObject<
    SampleInput,
    SampleBinging,
    SampleOutput
>
```

```swift
// implementations
final class SampleObservableObjectImpl: SampleObservableObject {
    let input: InputWrapper<SampleInput>
    let binding: BindingWrapper<SampleBinging>
    let output: OutputWrapper<SampleOutput>
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let input = SampleInput()
        let binding = SampleBinging()
        let output = SampleOutput()
        self.input = input.toWrapper()
        self.binding = binding.toWrapper()
        self.output = output.toWrapper()
        
        input.onTap
            .map { true }
            .prefix(1)
            .assign(to: \.isPresenting, on: binding)
            .store(in: &cancellables)
        
        binding.$isPresenting
            .filter { $0 }
            .prefix(1)
            .map { _ in "Sheet has presented" }
            .assign(to: \.text, on: output)
            .store(in: &cancellables)
    }
}
```
