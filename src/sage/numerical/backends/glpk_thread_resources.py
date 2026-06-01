"""
Shared thread-local GLPK resource tracking.

GLPK problem and graph objects use the same thread-local GLPK allocator state,
so pending releases from the LP and graph backends must be swept together.

TESTS:

The public collection helper is a no-op before the current thread has
registered any GLPK resources::

    sage: from sage.numerical.backends import glpk_thread_resources as resources_module
    sage: resources_module.collect_glpk_released_for_current_thread() is None
    True

Test the local resource collection helper with small fake resources::

    sage: from sage.numerical.backends.glpk_thread_resources import GLPKThreadResources
    sage: class RecordingResource:
    ....:     def __init__(self, name, events, released_error=None):
    ....:         self.name = name
    ....:         self.events = events
    ....:         self.released_error = released_error
    ....:     def _free_released_from_owner_thread(self):
    ....:         self.events.append(("released", self.name))
    ....:         if self.released_error is not None:
    ....:             raise self.released_error
    ....:     def _free_from_owner_thread(self):
    ....:         self.events.append(("final", self.name))

Missing resources can be discarded, and a collection with no pending releases
does not touch registered resources::

    sage: resources = GLPKThreadResources()
    sage: events = []
    sage: a = RecordingResource("a", events)
    sage: b = RecordingResource("b", events)
    sage: resources.add(a)
    sage: resources.add(b)
    sage: resources.discard(a)
    sage: resources.discard(a)
    sage: resources.resources == [b]
    True
    sage: resources.collect_released()
    sage: events
    []

Successful sweeps free pending resources and clear the retry flag::

    sage: resources.has_released = True
    sage: resources.collect_released()
    sage: events
    [('released', 'b')]
    sage: resources.has_released
    False

The destructor frees all resources that are still registered and clears the
registry::

    sage: resources = GLPKThreadResources()
    sage: events = []
    sage: resources.add(RecordingResource("a", events))
    sage: resources.__del__()
    sage: events
    [('final', 'a')]
    sage: resources.resources
    []

Released resources unregister themselves while they are being swept in the
real backends, so collection iterates over a snapshot::

    sage: class SelfDiscardingResource:
    ....:     def __init__(self, resources, name, events):
    ....:         self.resources = resources
    ....:         self.name = name
    ....:         self.events = events
    ....:     def _free_released_from_owner_thread(self):
    ....:         self.events.append(self.name)
    ....:         self.resources.discard(self)
    ....:     def _free_from_owner_thread(self):
    ....:         pass
    sage: resources = GLPKThreadResources()
    sage: events = []
    sage: resources.add(SelfDiscardingResource(resources, "a", events))
    sage: resources.add(SelfDiscardingResource(resources, "b", events))
    sage: resources.has_released = True
    sage: resources.collect_released()
    sage: events
    ['a', 'b']
    sage: resources.resources
    []
    sage: resources.has_released
    False

If a release sweep is interrupted, it leaves the retry flag armed so the
owner thread can try again later::

    sage: resources = GLPKThreadResources()
    sage: resources.add(RecordingResource("a", [], KeyboardInterrupt()))
    sage: resources.has_released = True
    sage: try:
    ....:     resources.collect_released()
    ....: except KeyboardInterrupt:
    ....:     pass
    sage: resources.has_released
    True

The public collection helper catches ordinary exceptions because it is called
from ``noexcept`` Cython accessors, and re-arms the retry flag::

    sage: thread_resources = resources_module.glpk_thread_resources()
    sage: old_resources = thread_resources.resources
    sage: old_has_released = thread_resources.has_released
    sage: events = []
    sage: thread_resources.resources = [RecordingResource("bad", events, RuntimeError("boom"))]
    sage: thread_resources.has_released = True
    sage: resources_module.collect_glpk_released_for_current_thread()
    sage: events
    [('released', 'bad')]
    sage: thread_resources.has_released
    True
    sage: thread_resources.resources = old_resources
    sage: thread_resources.has_released = old_has_released

Resource tracking is thread-local::

    sage: import queue
    sage: import threading
    sage: main_resources = resources_module.glpk_thread_resources()
    sage: q = queue.Queue()
    sage: def get_thread_resource_identity():
    ....:     q.put(resources_module.glpk_thread_resources() is main_resources)
    sage: t = threading.Thread(target=get_thread_resource_identity)
    sage: t.start(); t.join()
    sage: q.get()
    False
    sage: resources_module.glpk_thread_resources() is main_resources
    True
"""

import threading


_glpk_thread_data = threading.local()


class GLPKThreadResources:
    def __init__(self):
        self.resources = []
        self.has_released = False

    def add(self, resource):
        self.resources.append(resource)

    def discard(self, resource):
        try:
            self.resources.remove(resource)
        except ValueError:
            pass

    def collect_released(self):
        if not self.has_released:
            return
        # Clear the flag *before* sweeping: if a cross-thread release lands
        # mid-sweep it sets ``has_released`` back to True, and we must not
        # overwrite that (otherwise that pending free is deferred all the way
        # to owner-thread exit).  If the sweep is interrupted, re-arm the flag
        # so the owner thread retries the remaining resources later.
        self.has_released = False
        try:
            for resource in list(self.resources):
                resource._free_released_from_owner_thread()
        except BaseException:
            self.has_released = True
            raise

    def __del__(self):
        for resource in self.resources:
            resource._free_from_owner_thread()
        self.resources.clear()


def glpk_thread_resources():
    try:
        return _glpk_thread_data.resources
    except AttributeError:
        resources = GLPKThreadResources()
        _glpk_thread_data.resources = resources
        return resources


def collect_glpk_released_for_current_thread():
    try:
        resources = _glpk_thread_data.resources
    except AttributeError:
        return
    try:
        resources.collect_released()
    except Exception:
        # This is a best-effort cleanup sweep that runs from the ``noexcept``
        # accessors ``_lp_or_null``/``_graph_or_null``.  An exception escaping
        # here (e.g. ``MemoryError`` while building ``list(self.resources)``)
        # would, in a ``noexcept`` cdef function, be turned by Cython into an
        # *undefined* return value that callers dereference as a live pointer.
        # Swallow it instead and re-arm the flag: the only consequence is that
        # the pending cross-thread free is deferred to the next sweep (or to
        # owner-thread exit), never a crash.
        resources.has_released = True
