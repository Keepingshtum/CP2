'Script for Populating Feed
'Get feed data via roUrlTransfer
sub GetContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()
    rootChildren = {
       children: []
    }
    rowAA = {
        children: []
    }

    itemCount = 0
    rowCount = 0
'Parse Feed Data and make sure it displays properly
    for each xmlItem in responseArray
        print "xmItem Name: " + xmlItem.GetName()
        if xmlItem.GetName() = "item"'  
            itemAA = xmlItem.GetChildElements() 'itemAA contains a single feed <item> element
            if itemAA <> invalid
                for each xmlItem in itemAA
                        item = {}
                        if xmlItem.GetName() = "media:content" and Instr(1,xmlItem.GetNamedElements("media:title").GetText(),m.top.query) <> 0 'check if query is a substring of title
                            item.url = xmlItem.GetAttributes().url
                            xmlTitle = xmlItem.GetNamedElements("media:title")
                            item.title = xmlTitle.GetText()
                            xmlDescription = xmlItem.GetNamedElements("media:description")
                            item.description = xmlDescription.GetText()
                            item.streamFormat = "mp4"
                            xmlThumbnail = xmlItem.GetNamedElements("media:thumbnail")
                            item.HDPosterUrl = xmlThumbnail.GetAttributes().url
                            itemNode = CreateObject("roSGNode", "ContentNode")
                            itemNode.SetFields(item)

                            itemNode.AddFields({
                                handlerConfigRAF: {
                                    name: "HandlerRAF"
                                }
                            })

                            rowAA.children.Push(itemNode)
                    end if
                end for
            end if
            itemCount++
            if (itemCount = 4)
                print "Creating a new row"
                itemCount = 0
                rowCount++
                rowAA.Append({ title: "Row " + stri(rowCount) })
                rootChildren.children.Push(rowAA)
                rowAA = {
                    children: []
                }
            end if
        end if
    end for

    'Insert the last incomplete row if children array is not empty
    if (rowAA.children.Count() > 0)
        rowCount++
        rowAA.Append({ title: "Row " + stri(rowCount) })
        rootChildren.children.Push(rowAA)
    end if
    m.top.content.Update(rootChildren)
end sub

function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
end function
