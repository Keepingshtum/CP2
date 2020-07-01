
' Video Player logic- For use if you choose not to use prebuffering for backwards compatibiiity 
sub OpenVideoView(content as Object, index as Integer)
    video = CreateObject("roSGNode", "MediaView")
    video.content = content
    video.jumpToItem = index
    video.theme = {
        OverhangVisible : "false"
        trickPlayBarFilledBarImageUri :  "pkg:/images/bar.9.png"
        bufferingBarFilledBarImageUri : "pkg:/images/bar.9.png"
        bufferingBarEmptyBarImageUri : "pkg:/images/bar.9.png"
        bufferingBarTrackImageUri : "pkg:/images/bar.9.png"
    }
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    video.control = "play"
end sub
