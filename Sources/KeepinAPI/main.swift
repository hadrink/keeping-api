// Find a way to add a flag during the compilation.
// For example: swift build -c debug -Xswiftc -DQA

#if QA
print("hello, world");
#endif
