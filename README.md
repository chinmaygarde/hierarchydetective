Hierarchy Detective
===================

1. Visit [Hierarchy Detective](http://hierarchydetective.com/) for an overview of how to use the application and library in your own projects
2. Download the latest [release](https://github.com/chinmaygarde/hierarchydetective/releases)
3. Once you have the Mac application, explore a [few](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/examples/Catalog.hdet) [sample](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/examples/Emoji.hdet) [traces](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/examples/Segments.hdet) yourself.
3. This repository contains the source for the library that needs to be linked into the application. The code for the client application will be released very soon.

![Quartz Core](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/product/S1.png)
![Nav Bar](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/product/S3.png)
![Emoji](https://raw.githubusercontent.com/chinmaygarde/hierarchydetective/gh-pages/product/S4.png)

Getting Started
-----------
The easiest way to get started is to link the precompiled static library with your application. Once the application launches, the server starts up automatically and logs its status to the console. At this point, the device name should also show up in the list of servers in the desktop viewer.

The repository currently contains support for inspecting UIKit, Quartz and Cocos2D (versions 1 and 2) hierarchies. Two universal (i.e, can be used on both the simulator and actual devices) libraries are currently distributed. `libDetectiveUniversal.a` contains support for UIKit and Quartz. `libDetectiveCocos2DUniversal.a` adds support for Cocos2D.

Troubleshooting
--------------
Check out the [wiki](https://github.com/chinmaygarde/hierarchydetective/wiki) for a troubleshooting guide.

Contributing
-----------
The static library will always remain open source and all contributions are welcome.

Since Cocos2D is an open source project, modifications to the project by end users makes it difficult to guarantee that the viewer works are expected. If there are any issues, you can report them using the issue tracker, or, better yet, submit pull requests with fixes.

Also, it is extremely easy to add support for other view hierarchies. There is a lot if information in the wiki that details how you can go about doing just that. If you have added support for any other freely available view hierarchies, I would love to hear about it.

License
------
The Hierarchy Detective iOS library is released under the [MIT License](http://opensource.org/licenses/MIT).
