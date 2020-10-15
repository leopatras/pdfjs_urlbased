# pdfjs (URL based)
Shows how to use pdfjs with a URL based component to surround a GDC 3.20 issue


Prerequisites (server side)
  * gnu make 
  * patch
  * curl
  * bash

Running in GDC
```
  FGLSERVER=<yourgdc> make run
```

Run it in GDC via GAS
```
  make gdcwebrun
```
This assumes FGLASDIR is set and pointing to a valid GAS,
and the GAS/GDC/fglrun are on the same machine and GDC must be up and running.

Just run it in GBC
```
  make webrun
```
