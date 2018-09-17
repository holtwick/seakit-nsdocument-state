# NSDocument and States

An example of how to implement a central state in a `NSDocument` environment and use it for back and forward navigation by making use of `NSUndoManager`

#### Some bullet points

- Reference to document is available in `NSViewController` via `document` property, which is dynamically assigned
- On any change of `document` the respective `setupController` and `cleanupController` methods are called for custom document related setup
- A `state` object in the document class describes UI states, it is KVO compatible
- A helper can easily observe property changes
- Navigation between states is managed by an `NSUndoManager` instance
- A special container view class can load view controllers and pass the document reference
- The example includes first responder mapping to the state by `tag`
