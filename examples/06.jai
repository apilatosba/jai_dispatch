#import "Compiler";
#import "Basic";
#import,file "../ApilaDispatch.jai";

main :: () {
   InitializeThreads();

   items := NewArray(threadCount + 1, TLSItem(int), alignment = xx alignof(TLSItem(int)));

   workCount := 100000;
   for 0..workCount - 1 {
      DispatchFunction(Increment, items);
   }

   completedWorkCount := 0;
   while completedWorkCount < workCount {
      completedWorks := GetCompletedWorks();
      completedWorkCount += completedWorks.count;
   }

   sum := 0;
   for items {
      print("[%]: %\n", it_index, it);
      sum += it.item;
   }

   print("total: %\n", sum);
   assert(sum == workCount);
}

Increment :: (items: [] TLSItem(int)) {
   items[context.thread_index].item += 1;
}

alignof :: ($T: Type) -> s64 #expand {
    return #run -> s64 {
        info := type_info(struct{ p: u8; t: T; });
        return info.members[1].offset_in_bytes;
    };
}
