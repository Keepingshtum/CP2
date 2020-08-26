This repository hosts the channel files for a sample Roku Channel.

Please Consult the [Wiki](https://github.com/Keepingshtum/CP2/wiki) for instructions on how to use this repository.

# Project Goals
The main goal was to create an easy-to-use, well documented and easy to extend/customise template for creating a Roku channel.

This Was subdivided into the following goals:

- Create an simple and intuitive user interface and experience which emulates industry standards and best practices

- Lay the foundation for back-end services such as recommender systems- so users can integrate existing backend solutions into the template, or use their own

- Add support to enable users to implement paid subscriptions or custom feeds out-of-the box.

- Create a “ready to use” default version of the channel which can be immediately loaded onto roku without extra configuration.


# What is done?
- The basic UI functions are in place. 

- The channel is able to handle all sorts of media (All major streaming formats like MP3, MP4, HLS, DASH etc, longform and shortform content.)

- The backend for Recommender systems is done. 

- The channel is usable without extra configuration, only the content needs to be loaded into the feed, and the auth keys need to be replaced.

# What is left to do?
- A few of the components don't look so great. The progress bar specifically was a crucial component that's pending.

- Due to the rigid nature of Brightscript, a few features aren't so easily customisable, e.g Preloading/Non Preloading.

- Some QoL life features like Subtitles/ Video Trickplay images aren't available as of now.

# My takeaways from GSoC 2020

This really was an eye-opening experience for me, as this is my first serious attempt at writing code/ building something which might actually be used in the real world. There's a lot of ways to solve a problem, but most "quick and dirty" fixes will probably come back to trouble one if they're not careful! I realised this after nearly wiping out all the progress I made with just two lines of code (long story!) But in the end, what matters most is understanding a problem. I spent nearly a month fighting the Roku framework over auth details, and all because of a tiny detail I was missing. This was due to a gap in my understanding about how Roku authenticates with any service. The most important lesson is allocating appropriate time to things- it's so hard to predict which part one might get stuck on, and seemingly huge problems are solved in hours!

# Blog Posts

You can find all of the posts related to this project [here](https://medium.com/@anant.shukla16)

# Acknowledgements
A big thank you to my Mentor, Carlos Fernandez, for working with me tirelessly during the duration of the project. I wouldn't have gotten very far without his help! Google, for sponsoring this opportunity for me- it's been the most defining experience in my career so far! Various members of the Roku community, on the forums and Slack, for their pointers on how to pull off some of the more difficult problems. I'm grateful to you all!
