**Objective-Chain** is made up of *Foundation* and additional libraries that are built on top of it:

## [Foundation](./Foundation)
  - Defines abstract ***Producer*** and ***Consumer*** as well as some of their basic concrete subclasses: *Command*, *Bridge*, *Hub*, *Subscriber*.
  - Factories for the most essential ***Transformers*** and ***Predicates***.
  - Provides ***Accessor*** classes for accessing and modifying key-paths and structure members.
  - Implementes ***Property Bridge***, one of the main *Producers / Consumers* which uses KVO and KVC.
  - Wrapper for GCD queues as a ***Queue*** class, which is used by *Connections*.
  - Includes some utility categories and classes that are used in other classes.
  - Provides a set of ***Math*** transformers for doing arithmetic, rounding or trigonometry.
  
## [Geometry](./Geometry)
  - Provides ***Transformers*** and ***Predicates*** for working with geometric structures like *Point*, *Size*, *Rectangle*, *Affine Transfrom* and *Edge Insets* for iOS targets.

## UIKit
*To be implemented…*
