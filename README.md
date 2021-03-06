# development machine

Dockerimage with the system setup comprising programs that I use on a daily
basis:

1. Python
2. NodeJS
3. Go
4. Vim (with some additions)
5. ZSH (with oh-my-zsh)
6. Tmux

This is image is run by the user `dev`, which makes things easier when mounting
volumes into the container, so the host user will not be `root`.

Besides that, the volume `/home/dev/public` is exposed, so it's possible to
mount host projects into the container.

## run

To execute the container:

```bash
docker run -i -t --rm \
    --name devmachine \
    --hostname devmachine \
    --volume $HOME/public:/home/dev/public \
    joaodubas/devmachine
```

## todo

1. virtualenv/virtualenvwrapper for python (still thinking if I want this)
2. Docker (maybe, still thinking about DinD)

## LICENSE

Copyright (c) 2014 Joao Paulo Dubas <joao.dubas@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
