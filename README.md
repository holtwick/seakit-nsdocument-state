# NSDocument and States

An example of how to implement a central state in an `NSDocument` environment and use it for back and forward navigation by making use of `NSUndoManager`

#### Some bullet points

- Reference to document is passed to each view controller via `representedObject`
- A special container view class can load view controllers and pass the document reference
- A `state` object in the document class describes UI states, it is KVO compatible
- A helper can easily observe property changes
- Navigation between states is managed by an undo manager
- The example includes first responder mapping to the state