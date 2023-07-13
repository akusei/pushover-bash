## Using Pushover-bash with PHP's Composer

To use the pushover-bash script with composer, there are a few changes/additions to the instructions in the [README](README.md).

## Configuration

In addition to the default configuration file locations, you can also create the configuration file at the same location as your `vendor` folder. The script will traverse up 3 folders to look for it.

**Be sure to add it to your `.gitignore` file.
```.gitignore
/pushover-config
```

You can add and call it as a script in your composer.json file like so:

```json
{
    "scripts": {
        "pushover": "./vendor/bin/pushover $@"
    }
}
```

Then call it through composer like so:
```bash
composer pushover [script args]
```