Objective-Chain <a href="https://flattr.com/submit/auto?user_id=Tricertops&url=http%3A%2F%2Fgithub.com%2FiMartinKiss%2FObjective-Chain" target="_blank"><img src="https://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>
===============

Object-oriented reactive framework written in **Objective-C**, that abstracts _production_, _transformation_ and _consumption_ of values in a declarative way.

Project is inspired by [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), but takes more object-oriented approach.

Aim is to build reusable and scalable solution for **MVVM** bindings. [Article about MVVM implementation using Objective-Chain.](https://gist.github.com/iMartinKiss/bd038dfbf0663818b0ad)


##### Project can be reliably used in production. Follow the [Roadmap](https://github.com/iMartinKiss/Objective-Chain/issues/1) for progress.


Concept
-------

Everything happens for a reason and this is especially true in software. Basic principle of software is to receive input and provide output. **Reacting to events with actions**, but our actions can trigger new events. A reactive framework should allow you to write the rules declaratively. This means you **write it once and it works forever** (or at least until cancelled).

In iOS and OS X applications, we know multiple way to react on events: *Target + Action*, *Notifications*, *Key-Value Observing*, *Delegation* and *Blocks*. All of them have **different characteristics** and therefore they are used in different cases and using different APIs. Objective-Chain attempts to **unify these callback mechanisms** and allows you to easily receive events, filter or transform their values and subsequently execute actions or chain them to other events.


#### Event vs. Value

To avoid confusion, we should clarify the difference between *Event* and *Value*. The difference, for purpose of Objective-Chain, **is none**. Producing a *Value* is an *Event* and *Events* usually have some *Value* associated with them. And if not, *No Value* is still a *Value*.



Main Components
---------------

Core concept is really simple: ***Producers*** send values and ***Consumers*** receive them. _Producer_ and _Consumer_ are abstract terms, so the true functionality is provied by their concrete implementations.

### Producers

  - _**Timer**_ – Periodically sends time intervals to _Consumers_ until stopped.
  - _**Property**_ – Observes KVO notifications of given object and key-path and sends latest values to _Consumers_. It's one of the _Core_ features.
  - _**Notificator**_ – Observes `NSNotifications` with given name and sends them to _Consumers_.
  - _**Target**_ – Receiver of target-action callbacks that sends the sender to _Consumers_.
  - _**Command**_ – Generic _Producer_ to be used manually by invoking its methods.
  - _**Hub**_ – Special _Producer_, that takes multiple other _Producers_ and forwards their values. There are currently three kinds fof _Hub_: merging, combining and depending. More on those later.
  
  - In addition, you can easily subclass _Producer_ with custom implementation. If there are other sources of events/values that should be implemented, feel free to [suggest it](https://github.com/iMartinKiss/Objective-Chain/issues/new).

### Consumers
  - _**Property**_ – Yes, the same _Property_ as the _Producer_ above, but this time it set received values using KVC. Setting usually triggers KVO event, that is immediately produced. It's one of the _Core_ features.
  - _**Invoker**_ – Invokes regular invocations optionally replacing the arguments with received values. Don't worry, it has never been easier to create and use `NSInvocations`! It's one of the _Core_ features.
  - _**Subscriber**_ – Most versatile _Consumer_, that can be customized using blocks. Allows you to easily create ad-hod implementations of consumers, if there is no better alternative (and trust me, there usually is).
  - _**Switch**_ – Similar to `switch` or `if-else` control statements, _Switch_ takes multiple _Consumers_ with one _Predicate_ for each. Once it receives value, it invokes all sub-consumers whose predicates evaluate to `YES`.
  
  - There are some more provided _Consumers_, but they usually only uses _Subscriber_ to perform their task. If there are other special cases, that need custom subclass, [suggest them](https://github.com/iMartinKiss/Objective-Chain/issues/new).

These were only the endpoints of _Chain_, now the fun begins…

### Mediators
_Mediator_ is simply a _Producer_ **and** _Consumer_ that can stand in between and make changes to the values. It never produces new values and never uses them in a meaningful way.

  - _**Bridge**_ – Basic _Mediator_ that passes all values further. It is best when you want to expose a _Producer_ in object's interface. Optionally, and this is important, _Bridge_ can use a _Value Transformer_ to convert values before passing them to _Consumers_. This is one of the _Core_ features. More on _Transformers_ later.
  - _**Filter**_ – _Mediator_ that evaluates a _Predicate_ on the values. Those that evaluates to `YES` are passed without changes, otherwise they are ignored (discarded).
  - _**Context**_ – Interesting and flexible _Mediator_, that simply forwards the values. The point is, it sends them in a **known context**. For example, inside of animation block, or inside of `@synchronized` statement, or even send them on another _Queue_. _Context_ object is really simple, but allows you to do powerful things. More on _Queues_ later.
  - _**Throttle**_ – Time-aware _Mediator_. It forwards values with reduced frequency, for example when user types fast on keyboard, _Throttle_ can be configured to send latest entered text after 0.3 s pause.

## Creating Chains
You can use any of those provided components or create your own and chain them together to build the logic of your application. Examples:

1. **Listen for notification and invoke a selector:**
  
    ```objc
    [[OCANotificator notify:NSUserDefaultsDidChangeNotification]
     connectTo:OCAInvocation(self, reloadPreferences)];
    ```
    
    - `+notify:` – Creates a _Producer_ that **listens** for given notification.
    - `OCAInvocation` – Macro that creates `NSInvocation` for `[self reloadPreferences]` call.
    - `-invoke:` – Internally creates a _Consumer_ `OCAInvoker` with given invocation and attaches it to the _Notificator_. Target of the invocation is stored **weakly**.

2. **Anytime the name of user changes, display it in a label:**

    ```objc
    [OCAProperty(self, user.name, NSString)
     connectTo:OCAProperty(self, label.text, NSString)];
    ```
    
    - `OCAProperty` – **Macro** that creates an `OCAProperty` object. It takes a _target_, _key-path_ and a _class_ of values (`NSString` in both cases, more about class-validation later). _Property_ object can act as **both** _Producer_ and _Consumer_. This macro uses Xcode **autocompletion** and is validated during build time.
    - `-connectTo:` – Adds the argument to the receiver's list of _Consumers_. Any changes in `user.name` will be reflected by `label.text`.

3. **When text of text field doesn't change for 0.3 seconds, initiate search:**

    ```objc
    [[[self.textField producerForText]
      throttle:0.3]
     connectTo:OCAInvocation(self, startSearchWithText: OCAPH(NSString) )];
    ```
    
    - `-producerForText` – Creates `OCATarget` _Producer_ **configured** for the text field (receiver). Sends the entered text every time it changes.
    - `-throttle:` – Internally creates `OCAThrottle` _Mediator_ with given **delay**, attaches it to the receiver and returns it (so we can continue chaining). _Throttle_ will send the entered text only after it didn't change (nothing is received) for 0.3 seconds.
    - (`-invoke:` and `OCAInvocation` are described in the first example above)
    - `OCAPH` – Macro that is a short **alias** for `OCAPlaceholder`. When used as an argument of invocation passed to `OCAInvoker`, it will be **replaced by real value**. In this case, we used only **one** _Placeholer_, so the received text from text field (and throttled) will be passed to the invocation. Argument of the macro is class used for **validation**.


### Example Project
For more code examples see included _Chain Examples_ project. You can use it as a sandbox for experimenting with Objective-Chain and even submit a Pull Request, so your experiments will be merged into the master repo.


Additional Features
------------------
To be described later:

  - Class validation.
  - Transformers.
  - Predicates.
  - Queues.
  - Value boxing/unboxing.
  - Invocation catcher.
  - Decomposer.

Follow the [Roadmap](https://github.com/iMartinKiss/Objective-Chain/issues/1) for progress.

---

> Check it, load it, link it, use it,  
> View it, code it, quick - combine it.  
>
> Chain it, branch it, merge it, fork it,  
> Switch it, send it, bridge - transform it.
>
> Catch it, change it, call it, tune it,  
> Drag and drop it, box - unbox it.

---

Licensed under The MIT License (MIT)  
Copyright © 2014-2015 Martin Kiss
