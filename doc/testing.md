# Crunch Testing


## Unit testing

Unit tests can be run by 

    crunch -test
    
A list of tests will be printed:

    Crunch - unit testing

    Utility
       Dynamic_Arrays
          Basic_Test... ok

       Linked_Lists
          Basic_Test... ok
          Test_Size_N, N =  100... ok
          Test_Size_N, N =  10000... ok
          Test_Size_N, N =  1000000... ok
          Test_Size_N, N =  10000000... ok

       Binary_Search_Trees
          Simple_Test... ok
          Random_Test... ok
          Large_Test_1... ok
          Large_Test_2... ok

       Hash_Tables
          Basic_Test... ok
          Random_Test... ok


    Deflate
       Huffman
          Basic_Test... ok
          Test_Case_1... ok


## Code Coverage

In the absence of advanced testing framework, code coverage can only be
estimated manually. Unfortunately, the unit tests are not as thorough as
they should, since I ran out of time with the project. The most important and
complex algorithm, the Red-Black Tree, is tested quite well with a large 
randomized test routine. A special Verify procedure was implemented to
systematically check the red-black properties of the tree.
This actually helped me find a somewhat difficult bug
in the node removal routines, where the color properties of the tree are managed.


## System & Performance Testing

Compression/decompression cycle has been tried with numerous small and large files.
No data corruption has been detected. The compression speed varies around 1 to 1.5 MB/s.
Decompression is approximately ten times faster, usually around 15 MB/s.
The program requires about 10 times the size of the input file of memory.
