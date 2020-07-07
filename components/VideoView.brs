
' Video Player logic- For use if you choose not to use prebuffering for backwards compatibiiity 
sub OpenVideoView(content as Object, index as Integer)
    AddBookmarksHandler(content, index) 'Haven't tested if this way works- TODO for later
    video = CreateObject("roSGNode", "MediaView")
    httpAgent = CreateObject("roHttpAgent")
    httpAgent.HttpHeaders= "Authorization:Basic YW5hbnQ6c2FlN3V1YjNBaQ=="
    video.setHttpAgent(httpAgent)
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

'Adding bookmark handler to video- Remove copy in details view before you uncomment here
'sub AddBookmarksHandler(contentItem as Object, index = invalid as Object)
'    if index <> invalid then contentItem = contentItem.GetChild(index)
'    if contentItem = invalid then return
'    contentItem.AddFields({
'            HandlerConfigBookmarks: {
'            name: "RegistryBookmarksHandler"
'            fields: {
'                minBookmark: 10
'                maxBookmark: 10
'            }
'        }
'    })
'end sub