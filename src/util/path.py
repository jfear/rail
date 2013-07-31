"""
path.py

Module for manipulating and probing paths and files on the local filesystem.
"""

def is_exe(fpath):
    import os
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)
    
    fpath, _ = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file
    
    return None
