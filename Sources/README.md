**Objective-Chain** is made up of *Core* and additional libraries that are built on top of it:

## [Core](./Core)
  - Defines abstract ***Producer*** and ***Consumer*** as well as some of their basic concrete subclasses: *Command*, *Bridge*, *Hub*, *Subscriber*, *Multicast*.
  - Contains the ***Connection*** class which is main functional component of Objective-Chain.
  - Factories for the most essential ***Transformers*** and ***Predicates***.
  - Provides ***Accessor*** classes for accessing and modifying key-paths and structure members.
  - Implementes ***Property Bridge***, one of the main *Producers / Consumers* which uses KVO and KVC.
  - Wrapper for GCD queues as a ***Queue*** class, which is used by *Connections*.
  - Includes some utility categories and classes that are used in other classes.
  
## [Foundation](./Foundation)
  - A set of APIs to provide convenience use of Foundation classes.
  - Includes ***Transformers*** and ***Predicates*** for working with collections, strings, dates and many more.
  - Also includes Foundation-specifiic ***Producers*** and ***Consumers***: *Timer*, *Notificator*.
  - Provides a set of ***Math*** transformers for doing arithmetic, rounding or trigonometry.
  
## [Geometry](./Geometry)
  - Provides ***Transformers*** and ***Predicates*** for working with geometric structures like *Point*, *Size*, *Rectangle*, *Affine Transfrom* and *Edge Insets* for iOS targets.

## UIKit
*To be implemented…*
