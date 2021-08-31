# Tframework

Game user interface for Löve 2D, clean.

This framework is based on Zframework, with license information included.

## Design Principles

Tframework is loosely based on [HMVC](https://en.wikipedia.org/wiki/Hierarchical_model%E2%80%93view%E2%80%93controller):
- Every scene consists of a hierarchical system of GUI objects, all of which contains a Model-View-Controller triad.
- The controller receives input from either the user directly (for the top level GUI object), or get input from its parent object. You can easily interpret the raw input data (mouse positions, keyboard events, etc.) into compound gestures, e.g. flicks, double-taps, touch-and-holds.
- The view does the actual drawing work. Each layer of view draws on it's dedicated canvas, which are composed by parent views. Views only work when there is need to change the graphics, so static objects incur little overhead. Tframework takes care of the updating.
- The model is where all the game logic resides. The flexibility of lua makes it easy to implement all sorts of control flow, and it is easy to deal with even the cases that require breaking the HMVC pattern.
