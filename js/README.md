Node.js Language Binding for ev3dev 
=============

This is a Node.js module that exposes the features of the [ev3dev](http://github.com/ev3dev/ev3dev) API in an easy-to-use structure. It is part of the "unified" bindings project for ev3dev, which means it follows our abstract API specification. This specification is implemented in multiple languages so that one can easily carry the same code concepts from one language to another.

##Getting the Module
The easiest way to get the module is to install it through `npm`:

```
$ npm install ev3dev
```

And then `require()` it for use in your code.

You can also download the source from GitHub directly, either from the releases page or via git. If you do it this way, you will need to follow the building instructions below to make it usable from Node.

##Building From Source
This module is written in TypeScript, which means it cannot be directly used from JavaScript or Node.js. If you would like to make changes to the module or use a copy of the module from GitHub, you will need to follow these steps to build the module from source. The below steps should work on any modern OS, including Linux, OSX and Windows.

First, you will need to install some tools. Both building and running the module will require Node.js and `npm`, so make sure that you have both installed. Then install grunt, the task runner that we use to build the library:
```
$ npm install -g grunt-cli
```

Once you have done this, run `grunt --version` to make sure that everything was installed correctly (you may have to restart your terminal window first). Next you'll need to get the source code. You can `git clone` it to get the most recent changes, or download a release from the releases page. The following commands will need to be executed from the `js` directory of the source tree so `cd` in to that directory before continuing.

Now we will install the last few tools that we need. The list of dependencies for the module is pre-defined in the `package.json` file, so all we need to do is to tell `npm` to install them for us:
```
$ npm install
```

The final step is to run the build job. We can invoke the task runner that we installed earlier to do this:
```
$ grunt tsc
```

The build job should have put the generated JavaScript in the `bin` folder.
