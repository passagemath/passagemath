"""
Shared thread-local GLPK resource tracking.

GLPK problem and graph objects use the same thread-local GLPK allocator state,
so pending releases from the LP and graph backends must be swept together.
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
        if self.has_released:
            self.has_released = False
            for resource in list(self.resources):
                resource._free_released_from_owner_thread()

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
    resources.collect_released()
