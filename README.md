# MIPS Duplicate String Remover (MARS 4.5)
A tiny MIPS program that reads a comma-separated string, removing duplicates (first occurence wins), and prints the cleaned list.
> Input: `hello, world, minion, world, foo`  
> Output: `hello, world, minion, foo`

## Functions
- **parse:** splits str into item1..item6, into array (len: nb_items)
- **equals_str:** compares two strings (v0=1 equal, 0 otherwise)
- **build_new_arr** constructs new_array without dupes (len: new_nb_items)
- **build_string** joins new_items into final_str "a, b, c"
- **print_without_dup** runs above functions and prints final_str
- **main** lets user input str, processes it, print final_str, ask user if want to rep 
> Runs on **MARS 4.5**

## Skills Covered
- MIPS **calling conventions** (callee-saved `$s*` and `$ra`)
- **Stack discipline** (frame layout)
- **Pointers & arrays of pointers** (iterated with a running ptr `+4`)
- Worked with **syscalls** and ensured properly **control flow** 
