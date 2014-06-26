World Markers (for WildStar) [WIP]
=============

Place WoW-style world markers on the ground. [Hopefully] useful for showing people (and having them remember) where they should go in dungeons and raids.

![Screenshot](http://i.imgur.com/BfUrJOa.jpg)

API
---

I wouldn't rely on this yet, since it's likely to change once I get around to implementing syncing, but it sort of works for now.

Get a reference to the addon:

    local wm = Apollo.GetAddon("WorldMarkers")

Place a marker:

    wm:SetMarker(index, worldLoc)

Remove a marker:

    wm:ClearMarker(index)

Find all markers:

    wm.markers
