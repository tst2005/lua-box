
Lua Box
=======

Box like Sandbox.

What is different from other sandbox
====================================

Primary goal
------------

I make this util to setup more easily some isolated environement.
A sandbox is usualy a secure and fully isolated environment.
My box should be used to control/fiter/intercept partial content and allow to work with native environement (far to the sandbox definition).

Security
--------

Even I dropped the goal of a perfectly secure sandbox, I still keep in mind security consideration and made code as secure as possible.

Minimalist
----------

Trying to have a minimal requirement.

Inception
---------

This util should be able to be loaded inside a sandbox instance it-self : like an `inception` !


Structure
=========

* `box.lua` : the central obeject to create box instance and load/setup each part of the box environment
* `box/addons/*` : all addons and setup stuff
* mini/* : a separated minimal set of util, mainly some class system and env compat.

Current status
==============

* The projet is an alpha version.
* You can create lot of `box` instance.
* Inception works : you can load all the lua file inside a `box` instance.
* It is not optimized at all, it consume more memory than expected.


TODO
====

 * See what is consume so many memory.
 * Fix the `next`/`pairs`/`ipairs` behavior to follow the lua 5.2 behavior even in lua 5.1.
 * implement the `io`
 * implement a fully `fs` abstraction
 * split the `load` and `loadfile` (because loadfile need `io`/`fs`, but not `load`)
 * make `id` addon optionnal, allow of a direct use of `tostring`.
 * split addon and setup sutff, setup should use a direct function.
 * see to add acl


