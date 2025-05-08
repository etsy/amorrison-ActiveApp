# ActiveApp

This is a tool that records app usage on your mac to a CSV file.

## Running it

First, compile it. You'll need XCode to be installed on your machine along with it's CLI tools so that `swiftc` is available to you.

```bash
make
```

Then, run it as follows.

```bash
./build/activeApp | tee `whoami`.log
```

Once running you can just leave it alone and let it log which apps you're using, the window title and when the sample was collected.

## Sharing Data

Once you've collected some data please feel free to **doctor it** however you please.

Feel free to delete entries for things like

* Listening to Spotify
* Using your work laptop on the weekend
* Emailing family and friends
* Whatever you want.

