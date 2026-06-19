#import "Compiler";
#import "Basic";
#import,file "../ApilaDispatch.jai";

REPEAT_COUNT :: 10000000;

main :: () {
   InitializeThreads();

   // TLSItem version
   tlsItemVersionTime: int;
   {
      Increment :: (items: [] TLSItem(int)) {
         for 0..REPEAT_COUNT {
            items[context.thread_index].item += 1;
         }
      }

      items := NewArray(threadCount + 1, TLSItem(int), alignment = xx alignof(TLSItem(int)));

      startTime := current_time_monotonic();

      workCount := threadCount;
      for 0..workCount - 1 {
         DispatchFunction(Increment, items);
      }

      completedWorkCount := 0;
      while completedWorkCount < workCount {
         completedWorks := GetCompletedWorks();
         completedWorkCount += completedWorks.count;
      }

      stopTime := current_time_monotonic();
      tlsItemVersionTime = to_microseconds(stopTime - startTime);
      print("TLSItem version took % microseconds\n", tlsItemVersionTime);
   }

   // vanilla version
   vanillaVersionTime: int;
   {
      Increment :: (items: [] int) {
         for 0..REPEAT_COUNT {
            items[context.thread_index] += 1;
         }
      }

      items := NewArray(threadCount + 1, int);

      startTime := current_time_monotonic();

      workCount := threadCount;
      for 0..workCount - 1 {
         DispatchFunction(Increment, items);
      }

      completedWorkCount := 0;
      while completedWorkCount < workCount {
         completedWorks := GetCompletedWorks();
         completedWorkCount += completedWorks.count;
      }

      stopTime := current_time_monotonic();
      vanillaVersionTime = to_microseconds(stopTime - startTime);
      print("Vanilla version took % microseconds.\n", vanillaVersionTime);
   }

   if (tlsItemVersionTime < vanillaVersionTime) {
      print("TLSItem version was faster with a factor of %.\n", vanillaVersionTime.(float) / tlsItemVersionTime);
   } else {
      print("Vanilla version was faster with a factor of %.\n", tlsItemVersionTime.(float) / vanillaVersionTime);
   }
}

alignof :: ($T: Type) -> s64 #expand {
    return #run -> s64 {
        info := type_info(struct{ p: u8; t: T; });
        return info.members[1].offset_in_bytes;
    };
}
