## Weekly report #7

15 hours.

Finally, length-limited Huffman coding seems to be working really nicely
and compressing and decompressing files is possible.

To compress:

    crunch -c filename.txt
    
To decompress:

    crunch -d filename.txt_crunch
    
For now, the decompressed file is named filename.txt_crunch_deco to avoid messing
with the original.

You can Win-64 executable in the repo at

    obj/opt/crunch.exe


Progress:
* Fixed a problem in the package-merge algorithm
* Compress and decompress files using optimal Huffman code
* Started implementing LZ77 length-distance compression

Next week:
* Prepare an interesting demonstration
* Try to get LZ77 working
* Improve unit testing
* Clean up source code
* Finish documentation
* Clean up the UI to have a nice product by the final deadline
