## Manager source code
I created a `sample_edits.yaml` file that describes the list of `sample edits` on the website. I placed it in the `manager_source_code` folder. As a manager of the website I intend to update this file and associated thumbnail images to keep the list of my `sample edits` up to date.

This is the first `YAML` I created in my life. I included HTML formatting with URLs and quotation marks that I expect to see on the page. Not sure any of it is legal but at the end of the day it's a custom instruction file. Dear developer ♥ feel free to suggest whatever other format or convention for me to customize my sample edits in the future.

## Website behaviors
In this version the website is just a digital business card with only three expected user actions:
- send me an email;
- follow a link I provide in a sample edit;
- watch one of the sample edits right here on the website. 

### Video player
1. User clicks on a video thumbnail or a `CLICK TO WATCH` button.
2. Hovering embedded Vimeo player appears on top of the website.
3. Disappears when user clicks away.

When I ask Vimeo for the embed code here's what it gives me:
```
<div style="padding:45.42% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/1110117832?h=4e7e3098ae&amp;autopause=0&amp;player_id=0&amp;app_id=58479&amp;autoplay=1&amp;muted=1" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" style="position:absolute;top:0;left:0;width:100%;height:100%;" title="Salieri and Mozart (Short Film)"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>
```

I provide necessary values in `sample_edits.yaml`:
```
vimeo_id: 1110117832
vimeo_access_key: 4e7e3098ae
vimeo_title: Salieri and Mozart (Short Film)
```