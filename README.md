# Bucketful

Deploys static websites to Amazon S3.



### Description

Bucketful takes a local directory and copies all of its content to a given Amazon S3 bucket. If the bucket does not exist, Bucketful creates it. Then the bucket is configured to act as a website, i.e. all of the files get public read access for everyone and a file is assigned (typically index.html) to act as starting point for the site and a response is set for 404's. Optionally a CNAME is added to the DNS configuration of the domain, to make the site accessible at the expected url.

There's no interactivity required; set the configuration once and you'll be able to deploy like there's no tomorrow.



## Install

`npm install -g bucketful`

You can stick to a local install, `npm install bucketful`, if at least one of the following are true:

- You're only going to use bucketful programatically.
- You're only running the CLI via npm scripts.
- You have added ./node_modules/.bin to your path environment variable.



## Usage

Before getting started, make sure you have created an account at [Amazon Web Services](https://console.aws.amazon.com) and that you have the *Access Key* and *Secret Token* readily available.

You should also have created a folder with some files (html, js, css, images etc) that you want to deploy as a website.

### On the command line

Simplest possible usage:

`bucketful --source my/path --bucket something.something.dark.com --key ABCD --secret XYZW`

The `key` and the `secret` are the AWS *Access Key* and *Secret Token* respectively. The `bucket` name can be anything, but the whole idea is to access it as a website so it should probably be a domain you own.

Instead of having to type the arguments all the bloody time, you can put them in your `package.json` file, under the key `bucketful`, like this:

``` js
  {
    "bucketful": {
      "source": "my/path",
      "bucket": "something.something.dark.com",
      "key": "ABCD",
      "secret": "XYZW"
    }
  }
```

As long as you're running bucketful from the folder where `package.json` is you'll just have to run the following on your command line now:

`bucketful`

Easy, right?

If you want to, you can override the configuration found in the file by passing command line arguments:

`bucketful --bucket something.something.complete.com`

This will use the same settings as the before, but deploy to `something.something.complete.com`.

Since you probably commit your `package.json` but don't want to put secret tokens into committed files, there are a number of additional ways to supply options.



### Additional ways to supply options

So bucketful options can be given as arguments to the executable or put into `package.json`. But you're looking for more. Well then!

Bucketful accepts an option called `configs` that can be used to choose which file(s) to read configuration from. Simply give it as a command line argument:

`bucketful --configs somewhere/else/another_file.json`

Now the file `another_file.json` will be used instead of `package.json` to read the rest of the arguments.

You can even supply multiple files separated with semicolon if you want to:

`bucketful --configs "package.json;somewhere/else/another_file.json"`

Now why would you want to do that? Well, if you want to check your config into source control but exclude secrets, you kind of have to load from two sources. So in this case, the non-secret things could be in `package.json` and the secrets (which are not commited) could be in `somewhere/else/another_file.json`.

The default value for configs is actually `package.json;config.json`, so the convention is to use `config.json` as storage for your secrets.

Yet another option is to use the file `~/.bucketful` (also on the json format). That one is always loaded, regardless of what you specify in the configs-parameter. That way you can extract common settings that are not specific for a particular project (like your company AWS stuff, possibly) once for all projects.

If files are not enough for you, you can also use environment variables, like this:

`bucketful__key=ABCD bucketful__secret==XYZW bucketful`

That will read `package.json`, `config.json` and `~/.bucketful` just as usual, but also the key and secret as expected. That is particularly useful in CI-environments and the like.



### Resolution order

If an option is given in two or more of these ways, then the more "local" one will take precedence. The exact order, from strongest to weakest, is what follows:

* Command line arguments
* Files read from --configs, from first to last
* Environment variables
* ~/.bucketful

Note that all arguments can be given in all of these ways. Except `configs`. That would be weird. It can only be supplied via the command line.

Out of uniformity, the command line arguments can be given on the format `bucketful:option` as well, as to express the same namespacing as the files and environment variables enforce. So this is perfectly valid:

`bucketful --key ABCD --bucketful:secret XYZW`



### Additional options

#### region

Usage: `bucketful --region eu-west-1`

Creates the bucket in the given AWS region. If the bucket already exists when bucketful is run, then this option is ignored. It will NOT change the region of an existing bucket.

At the time of writing, Amazon accepts the following region values:

* us-east-1 (US Standard; Northern Virginia and Pacific Northwest)
* us-west-1 (US West; Oregon)
* us-west-2 (US West; Northern California)
* eu-west-1 (EU; Ireland)
* ap-southeast-1 (Asia Pacific; Singapore)
* ap-southeast-2 (Asia Pacific; Sydney)
* ap-northeast-1 (Asia Pacific; Tokyo)
* sa-east-1 (South America; Sao Paulo)

If no option is given, us-east-1 will be used.

Amazons up-to-date list of valid region names can be found in [Amazon's own documentation](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

#### index & error

Usage: `bucketful --index start.html --error wtf.html`

The `index` configures the bucket to use the given file as the response when a request is issued to the root path of the domain. The default value for this parameter is `index.html`.

The `error` configures the bucket to use the given file as the response when a request is issued for a file that doesn't exist. Or in other words, this file will be served as the 404 response. The default value for this parameter is `404.html`, if such a file exists in the deployed folder. If no such file exists, it will use the same file as `index`, which is reasonable for single page apps.

The configuration given with these two arguments will always be executed, regardless of whether the bucket already existed or not.

#### dns

Usage: `bucketful --dns bucketful-loopia`

The value of this argument should be the name of a bucketful plugin package. The plugin will then be used to update a DNS configation to make the site available at the domain given as bucket name.

How the DNS provider is choosen, how authentication happens and how the configuration itself is updated is all up to the plugin. Read more about that in the documentation of each individual plugin.

Known implementations:
* [bucketful-loopia](https://github.com/jakobmattsson/bucketful-loopia)

Want to write a plugin for your DNS provider? Can't figure out how? Feel free to get in touch!

#### Moar

The full list of options, summarizing all of the above, can be found by running `bucketful --help`



## Programmatic usage

Bucketful can be required like all other npm modules. It exposes two functions; `load` and `deploy`

``` js
  var bucketful = require('bucketful');
  var loaded = bucketful.load();
  bucketful.deploy({}, function(err) {
    // ...
  });
```

### bucketful.deploy

The `deploy` function does pretty much the same thing as the command line version of bucketful, but doesn't read any options automatically. Everything has to be provided as an argument to the function.

``` js
  var bucketful = require('bucketful');
  bucketful.deploy({
    key: 'ABCD',
    secret: 'XYZW',
    bucket: 'something.something.dark.com',
    source: 'my/path'
  }, function(err) {
    // This will be invoked when the deploy is finished.
    // If successful, err will be falsy.
    // If it failed, err will contain an Error-object.
  });
```

In addition to all the arguments accepted by the command line version, the `bucketful.deploy` function also accepts an argument called `output`. If given a stream, for example `process.stdout`, it will print verbose progress information (the same at the command line client prints) to that stream. If the `output` argument is not set, the function will run in silence.

``` js
  var bucketful = require('bucketful');
  bucketful.deploy({
    output: process.stdout, // logging is on!
    key: 'ABCD',
    secret: 'XYZW',
    bucket: 'something.something.dark.com',
    source: 'my/path'
  }, function(err) {
    // ...
  });
```

### bucketful.load

The `load` function reads all arguments from all sources decribed above and resolves them just the same way. It returns an object with the final set of arguments:

``` js
  var bucketful = require('bucketful');
  var conf = bucketful.load();
  console.log(conf); // { key: 'ABCD', secret: 'XYZW', bucket: 'something.something.dark.com', source: 'my/path' }
```

It also accepts an object with overrides for the arguments. This can be thought of as the strongest of all resolutons mechanisms:

``` js
  var bucketful = require('bucketful');
  var conf = bucketful.load({ bucket: 'something.something.complete.com' });
  console.log(conf); // { key: 'ABCD', secret: 'XYZW', bucket: 'something.something.complete.com', source: 'my/path' }
```



### Putting it together

So, essentially what the command line interface does is the following:

``` js
  var bucketful = require('bucketful');

  var conf = bucketful.load();
  conf.output = process.stdout;

  bucketful.deploy(conf, function(err) {
    if (err) {
      process.exit(1);
    }
  });
```

If you want to extend bucketful or integrate in into another environment, you can use this as boilerplate and add your own glue.



## ToDo / Wishlist

### Prio

* If the bucket is created in one region, but then bucketful is executed with an another region argument, what should happen? warning? error? print the right thing!
* Is a new "Grant" added every time "giveEveryoneReadAccess" runs now? Check it out and if so, stop it.

### Maybe

* Add travis badge and npm badge and coveralls badge to readme
* Log total progress of uploads with respect to filesize rather than number of started files (both would be best)
* Use colors in the text logging (to highlight the configed parts when printing)
* Implement a dns plugin for Amazon Route 53.
* Implement optional CloudFront configuration.
* GZip-support.
* Possibility to set caching headers.
* Option for setting max number of concurrent S3-uploads.
* Grunt plugin.
* Implement a CDN-provider other than amazon as backend.



## Contributions

Implementations of the above, or other neat things, are very welcome.

Include tests unless there's a very good reason not to.



## Author

Jakob Mattsson, [@jakobmattsson](https://twitter.com/jakobmattsson)



## License

MIT
