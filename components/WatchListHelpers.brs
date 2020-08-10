' function for getting Watchlist status for item by id
' read Watchlist from registry
'TO DO: Implement Server based versions of these as well

function Watchlist_GetWatchlistData(id as Object) As Integer
    ?"Watchlist_GetWatchlistData(" id ")"
    sec = CreateObject("roRegistrySection", "Watchlists")
    ' check whether Watchlist for this item exists
    if sec.Exists("Watchlist_" + id.ToStr())
        return sec.Read("Watchlist_" + id.ToStr())
    end if
    return 0
end function

' function for setting Watchlist status for item by id
' write Watchlist to registry
sub Watchlist_SetWatchlistDataTrue(id as String)
    ?"Watchlist_SetWatchlistData(" id "," ")"
    sec = CreateObject("roRegistrySection", "Watchlists")
    sec.Write("Watchlist_" + id, "true")
    sec.Flush()
end sub

sub Watchlist_SetWatchlistDataFalse(id as String)
    ?"Watchlist_SetWatchlistData(" id "," ")"
    sec = CreateObject("roRegistrySection", "Watchlists")
    sec.Write("Watchlist_" + id, "false")
    sec.Flush()
end sub

' function for removing Watchlist from registry
sub Watchlist_DeleteWatchlist(id as String)
    ?"Watchlist_DeleteWatchlist(" id ")"
    sec = CreateObject("roRegistrySection", "Watchlists")
    sec.Delete("Watchlist_" + id)
    sec.Flush()
end sub

'sub SaveWatchlist()
'    content = m.top.content
'    position = m.top.position
'    Watchlists_SetWatchlistData(content.id, position)
'end sub

'function GetWatchlist() as Integer
'    content = m.top.content
'    return Watchlists_GetWatchlistData(content.id)
'end function

'sub RemoveWatchlist()
'    content = m.top.content
'    Watchlists_DeleteWatchlist(content.id)
'end sub

