## Example Program
```jai
#import,file "../ApilaDispatch.jai";
#import "Basic";
#import "Thread";

main :: () {
   InitializeThreads();

   workCount := 2;

   sum: int;
   multiply: int;
   DispatchFunction(Sum, 34, 35, *sum);
   DispatchFunction(Multiply, 3, 23, *multiply);

   while workCount > 0 {
      completedWorks := GetCompletedWorks();
      workCount -= completedWorks.count;
   }

   print("sum:       %\n", sum);
   print("multiply:  %\n", multiply);
}

Sum :: (a: int, b: int, result: *int) {
   result.* = a + b;
}

Multiply :: (a: int, b: int, result: *int) {
   result.* = a * b;
}
```
