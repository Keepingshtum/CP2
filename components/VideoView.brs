' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********
' Video Player logic - Edit here for progress bar? (wip)
sub OpenVideoView(content as Object, index as Integer)
    video = CreateObject("roSGNode", "MediaView")
    video.content = content
    video.jumpToItem = index
    video.theme = {
        OverhangVisible : "false"
    }
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    video.control = "play"
end sub
