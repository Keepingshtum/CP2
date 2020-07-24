# Installing the channel on your Roku

Clone the repo onto your PC and extract the files. You'll find a file called bundle.zip, which you can upload to your Roku to see what the channel has to offer.
To do this, follow the below steps:

### Step One: Enable Developer Mode
Head to your living room, then turn the Roku on. Enabling developer mode starts by pressing a particular sequence of buttons on the official Roku remote (not the remote app on your phone.) In order, press:

- Home three times

- Up two times

- Right once

- Left once

- Right once

- Left once

- Right once.

Do all that and you should see the Developer Sceen.


Write down the IP address and the username seen here, because you’re going to need them later. Once you’ve got that information, select “Enable installer and restart,” then hit “OK” on your remote. You’ll be asked if you agree with the SKD License Agreement:

Click I Agree, then you’ll be asked to pick a development webserver password.

Take note of the password you set, ideally in the same place you took note of your IP address and username earlier. Your Roku will now restart. Once it’s booted, you can access Developer Mode.

### Step Two: Access Developer Mode
On a computer **connected to the same network** as your Roku, open your web browser. Paste the IP address you wrote down earlier in the URL bar, then hit Enter, and you’ll be asked for your username and password.


Enter them, then click “Log in,” and your browser will open developer mode.

### Step Three: Upload Your App to the Roku
Your browser has now opened the Development Application installer.

Click the “Upload” button, then point your browser toward your bundle.zip file.



The file name should be beside the “Upload” button.



Click “Install” and the installation process will begin. When its done, your app will instantly open on the Roku.


# Using this repository / Customising this channel

This channel basically has all the features a typical user would need- so the idea is all an end user (e.g you, the reader) need to do is modify the feed url to populate the channel. 

The Channel supports 3 types of content:

1. Normal Short form videos

2. Series content

3. Audio-only content (Music, podcasts)

The Channel can support all these at once, or you can choose to forgo some types of content. It is all dependent on what content you want on your channel!

This brings us to the first part of using this channel:

### Part one: Customising the feed

You can find the feeds in [this](https://github.com/Keepingshtum/CP2/tree/master/feeds) section. There's two, feed, and feed_recco. As the name might suggest, there's one for using a recommender system (not implemented in the channel, but can be used to actually fetch recommendations if needed)

Observe the fields carefully- 


~~~ 
"movies": [
    {
      "id": "00004",
      
      "title": "Arduino Tutorial",
      
      "releaseDate": "2015-06-11",
      
      "shortDescription": "Curious about how to solder a connection on an Arduino board? Look no further!",
      
      "thumbnail": "https://fremicro029.xirvik.com/downloads/Thumbnails/ArduTech.png",
      
      "genres": [
      
        "technology"
        
      ],
      
      "tags": [
      
        "tech"
        
      ],
      
      "content": {
      
        "dateAdded": "2015-06-11T14:14:54.431Z",
        
        "captions": [],
        
        "videos": [
        
          {
          
            "url": "https://fremicro029.xirvik.com/downloads/Roku%20videos/Tech/Tech.mp4",
            
            "quality": "UHD",
            
            "videoType": "MP4"
            
          }
          
        ],
        
        "duration": 38
      }
    },
~~~
This is how a typical entry will look. You will need to modify all these fields to replace the stock footage with your own content.
This applies to all video form fields. Note that while you can put anything in the "tags" field, the genre needs to be one of the fields in the genres section [here](https://developer.roku.com/en-ot/docs/specs/direct-publisher-feed-specs/json-dp-spec.md#genres)

The quality can be SD/HD/UHD.
videoTypes can be found [here](https://developer.roku.com/en-ot/docs/specs/direct-publisher-feed-specs/json-dp-spec.md#video) (see the videotype section of the table)

Series fields start off with a series title, then a list of episodes subdivided into seasons. The format remains the same for individual videos, however.

For the sake of parsing music/audio only items conveniently, audio item URLs are also listed under the "videos" content field in the feed. No need to worry- as long as you're inputting these under the "Music" heading, the channel will know what to do with the MP3!

You need to replace all the links with your own, replace the titles and the relevant fields, then host your feed.json on a webserver somewhere.

(To do: Address replacing feed link in config)

**Important note**: This implementation has been done using a simple seedbox with basic authentication. You'll need to enter these details in the authentication fields (To do: address this in config)

If you're using a non authenticated web server e.g something like a website server which serves MP4 files without authentication, you're fine. 

If you're using a CDN which has a separate Auth key, there's a bit of code-tweaking to be done. (To do: address this in config)


### Part two: Configuring Channel Logos and theming 
Head over to the [images](https://github.com/Keepingshtum/CP2/tree/master/images) folder.

Here, you will find a full set of images that you will need to replace (named *exactly* the same, mind) to replace your logos in the channel.

There's three sets of images:

icon(side and focus)- these will be seen from the Roku home screen.

splash(hd and fhd)- for the splash screen, i.e the screen the users will see on channel entry

logo- this is for the channel overhang, which will always be displayed on the left hand corner of the channel.

(optional) bar.9.png- a 9-patch image to configure the colour of the progress bars. This can be left as-is, if you prefer.

One last thing: Head over to the [manifest](https://github.com/Keepingshtum/CP2/blob/master/manifest) file and change the title to your channel name.

(Quick note: on updating your channel, you'll have to increment your build versions to comply with Roku certification here)

And you're done! Having replaced all these files and updating your feed, re-zip your files and sideload onto the Roku and voila- you have your own custom roku channel!

### Features that can be customised currently

The channel content and descriptions ([how?](https://github.com/Keepingshtum/CP2#part-two-configuring-channel-logos-and-theming))

The channel icons/ overhang ([how?](https://github.com/Keepingshtum/CP2/blob/master/README.md#part-two-configuring-channel-logos-and-theming))

The order of how content shows up ([how?](https://github.com/Keepingshtum/CP2/blob/master/README.md))


# To Do:

Add Screenshots
Add Section on Channel certification/Publishing to Roku
Add Config file for ease of customisability

More content will come here soon!
You can follow the development on my blog (new post weekly) https://medium.com/@anant.shukla16
