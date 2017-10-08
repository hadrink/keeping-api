// Find a way to add a flag during the compilation.
// For example: swift build -c debug -Xswiftc -DQA
import Vapor

#if QA
print("hello, world");
#endif

let drop = try Droplet()

drop.get("hello") { req in
    return "Hello Vapor"
}

try drop.run()
