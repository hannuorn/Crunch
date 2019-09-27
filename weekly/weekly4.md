## Weekly report #4

During the 4th week I was quite busy and only spent about 10 hours on the project.

There is now an executable for Windows in the repository:  obj/opt/crunch.exe

The program can now
* read a file
* "compress" it using fixed Huffman codes only
* write the result to a file
* measure compression performance

The output file is actually larger than the input file, since the fixed
Huffman code alone cannot achieve any real compression.

Plan for next week:
* Start writing implementation & testing documents
* Implement Huffman algorithm for creating an optimal Huffman code for given data
* Implement decompression routines
* Write unit tests (which are still missing, mostly, unfortunately)
* Allow larger files to be compressed in a reasonable time


### Example

    C:\Git\Crunch\obj\opt>crunch testfile
    Crunch
    
    Reading testfile...
    Size:  47701816 bytes
    Reading time:  8.845504300 seconds
    Speed:  5.14295E+00 MB/s
    
    Compressing...
    Compression speed:  2.18854E+00 MB/s
    
    Writing _crunch...
    
    C:\Git\Crunch\obj\opt>dir testfile*
     Volume in drive C has no label.
     Volume Serial Number is 52C3-9E7A
    
     Directory of C:\Git\Crunch\obj\opt
    
    04.09.2019  17.22        47 701 816 testfile
    28.09.2019  00.35        50 683 914 testfile_crunch
                   2 File(s)     98 385 730 bytes
                   0 Dir(s)  1 074 125 635 584 bytes free
    
    C:\Git\Crunch\obj\opt>



### Style Checking & Unit Testing

There is a tool called GNATcheck that can perform style checks on Ada code. 
There is also a tool GNATtest for creating unit tests.
Unfortunately, both of these tools are part of the commercial GNAT Pro product,
and are not available for free download, even for non-commercial use.

Therefore, I will do my best to manually take good care of code style
and write comprehensive unit tests.


### Performance & Scalability

At the moment the program seems to handle only about 2 megabytes per second.
This was easy to expect considering the naive handling of arrays of bits.
Larger files (e.g. 200 megabytes) cause the program to crash, since the
GNAT Ada runtime seems to be unable to create an array of billions of elements
(again, not surprising). Both of these problems can probably be addressed
quite easily by redesigning the generic package Dynamic_Arrays.
