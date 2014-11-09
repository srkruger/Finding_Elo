# From <http://thenestofheliopolis.blogspot.nl/2011/01/how-to-implement-non-blocking-two-way.html>

import select
import subprocess as subp

class Pipe(subp.Popen):
    def __init__(self, exe, args = None, timeout = 0):
        self.timeout = timeout
        argv = [exe]
        if args != None:
            argv = argv + args
        subp.Popen.__init__(self, argv, stdin = subp.PIPE, stdout = subp.PIPE, stderr = subp.STDOUT)

    def close(self):
        self.terminate()
        self.wait()

    def write(self, data):
        poll = select.poll()
        poll.register(self.stdin.fileno(), select.POLLOUT)
        fd = poll.poll(self.timeout)
        if len(fd):
            f = fd[0]
            if f[1] > 0:
                self.stdin.write(data)

    def read(self, n = 1):
        poll = select.poll()
        poll.register(self.stdout.fileno(), select.POLLIN or select.POLLPRI)
        fd = poll.poll(self.timeout)
        if len(fd):
            f = fd[0]
            if f[1] > 0:
                return self.stdout.read(n)

    def readlines(self, n = 1):
        c = self.read()
        string = ""
        while c != None:
            string = string + str(c)
            c = self.read()
        return string

    def set_timeout(self, timeout):
        self.timeout = timeout


