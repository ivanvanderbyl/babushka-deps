Install Chef with Babushka
==========================

**This is a snippet from my [blog post "Bootstrapping Chef in one command with Babushka"](http://ivanvanderbyl.github.com/2011/05/28/bootstrapping-chef-with-babushka.html)**


Install wget if not already installed:

    apt-get install wget
    
Bootstrap babushka using babushka:

    bash -c "`wget -O - babushka.me/up`"

Follow the default prompts and you should be good to go.

Next we run my `'chef user'` dep:

    babushka ivanvanderbyl:'chef user'
  
Notice how we don't have to tell Babushka where to get it from? By default Babushka looks for a Github repository called `<GITHUB USERNAME>/babushka-deps.git` and clones it, then loads it into its internal list.
[My babushka-deps repo](http://github.com/ivanvanderbyl/babushka-deps) contains the dep `chef user`

This will run the list documented below, and towards the end create a new user account. Make sure you don't call the user `chef` because it will cause things to fail in the next step. I usually use `deploy`

Now logout from root and reconnect as the chef user you just created to complete the next step: actually installing chef-server.

Install Chef
---------------------

This is where the magic happens, run this dep and you will have a complete Chef Server installation, optionally with `chef-server-webui`

    babushka ivanvanderbyl:'bootstrapped chef'

This will verify that all services have started correctly and if so report success, otherwise it will output a log file so you can trace what happened and hopefully fix the problem. (Please report bugs with this process below)

Contributing
========================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch e.g. git checkout -b `feature/my-awesome-idea` or `support/this-does-not-work`
* Commit and push until you are happy with your contribution
* Issue a pull request

Authors
=======
Ivan Vanderbyl - [@IvanVanderbyl](http://twitter.com/IvanVanderbyl) - [Blog](http://ivanvanderbyl.github.com)

Copyright
=========

Copyright (c) 2011 Ivan Vanderbyl.

License
=======

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

