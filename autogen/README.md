# Autogen scripts for ev3dev language bindings
To help us maintain our language bindings, we have written a script to automatically update sections of code according to changes in our API specification. We define code templates using [Liquid](http://liquidmarkup.org/), which are stored in the `templates` folder with the `.liquid` extension.

## Usage

### Prerequisites
- Make sure that you have cloned the repo (including submodules) and `cd`d in to the autogen directory
- You must have Node.JS and `npm` installed
- If you have not yet done so yet, run `npm install` to install the dependencies for auto-generation

### Running from the command line
If you run the script without any parameters, it will auto-generate all language groups:
```
$ node autogen.js
```

If you would like to only process a single group (as defined in `autogen-list.json`), you can provide the name of the group as a command-line parameter:
```
$ node autogen.js docs
```

## How it works
Our script searches code files for comments that define blocks of code that it should automatically generate. The inline comment tags are formatted as follows (C-style comments):

```
//~autogen test-template foo.bar>tmp
...
//~autogen
```

After the initial declaration (`~autogen`), the rest of the comment defines parameters for the generation script. The first block of text up to the space is the file name of the template to use. The `.liquid` extension is automatically appended to the given name, and then the file is loaded and parsed.

The rest of the comment is a space-separated list of contextual variables. The section before the `>` defines the source, and the section after defines the destination. The value from the source is copied to the destination, in the global Liquid context. This makes it possible to use a single template file to generate multiple classes.

##Implementation Notes
**TODO**
