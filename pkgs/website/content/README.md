# Updating the sample edits

The sample edits on the website come from one file, [sample_edits.yaml](sample_edits.yaml), and the thumbnail images in [web/images/thumbnails](../web/images/thumbnails). To change the list, edit the file and add or replace images. You don't need to touch any code.

## What changed from your draft

Your draft worked, and its content is all there. The format changed in a few places so that editing it later takes fewer steps:

1. Sample edits are a list. Each one starts with `- ` instead of `sample_edit_1:`, so you can reorder them by moving a block, with nothing to renumber.
2. `title` and `description` take a list of lines instead of `title_line_1`, `title_line_2` and so on. Use as many lines as you need, one `- ` per line.
3. Leave out a line you don't need instead of writing `none`. A public video has no `vimeo_access_key` line, and a sample edit with nothing under the title has no `description`.

The file also has three content fixes to match the design. Tell the developer if any of them is wrong:

1. The third sample edit's title is "Professional Reel" on one line. The draft had "Professional reel" with a second line, "into festivals", copied from the trailer.
2. There is a period after "7 Palms Entertainment", as in the design.
3. The link to 7 Palms Entertainment opens in a new tab, so visitors keep the business card open.

## Adding a sample edit

1. Upload the video to Vimeo. Its address looks like `vimeo.com/1110117832`, or `vimeo.com/1110117832/4e7e3098ae` for an unlisted video.
2. Save a thumbnail as a 1024 x 576 JPG in `web/images/thumbnails/`. Use a file name without spaces, like `thumbnail_newfilm.jpg`.
3. In `sample_edits.yaml`, copy an existing block, from its `- vimeo_id:` line down to the line before the next `- vimeo_id:`, and paste it where the new sample edit should appear.
4. Change the values:
   1. `vimeo_id` is the number from the address.
   2. `vimeo_access_key` is the code after the number, for unlisted videos only. For a public video, delete the line.
   3. `vimeo_title` is the video's name. Screen readers announce it, so keep it readable.
   4. `thumbnail_image` is the image's file name.
   5. `title` and `description` are the lines of text, one `- ` per line.
5. Check the result (see below).

Keep the indentation as it is: two spaces before `- vimeo_id`, four spaces before the other fields and six before each line of text. YAML uses the spaces to tell what belongs to what, and it doesn't accept tabs.

## Formatting text

Titles and descriptions accept three HTML tags:

1. `<b>bold</b>`
2. `<i>italic</i>`
3. `<a href="https://example.com">a link</a>`, with the full address including `https://`

You can nest them, as in `<b><i>Salieri and Mozart</i></b>`. Every tag needs its closing tag on the same line. Any other tag is an error, so a typo can't slip through to the site.

Titles are medium weight, so `<b>` there makes text bold. Descriptions are regular weight, so `<b>` there makes text medium, like the link in the first sample edit.

## Lines that need quotes

Most lines work as they are, quotes and dashes included. Wrap the whole line in single quotes if it:

1. contains a colon followed by a space, as in `Runtime: 12 minutes`;
2. contains a space followed by `#`, which would start a comment;
3. starts with a quote mark, `[`, `{`, `&`, `*`, `!`, `|`, `>`, `%` or `@`.

Inside single quotes, write an apostrophe as two apostrophes:

```yaml
    description:
      - 'Runtime: 12 minutes. It''s a short.'
```

## How lines look on the site

On computers and tablets, each line you write is its own line on the site, as in the design. On phones there is less room: description lines join into one paragraph, while title lines stay separate.

## Checking your changes

Ask the developer to set you up, or follow the "Development" section of the [project README](../../../README.md). Then, in the `pkgs/website` folder:

1. Run `jaspr serve` and open http://localhost:8080. Reload the page after each change to the file.
2. Run `jaspr build` to produce the site for upload.

If something in the file is wrong, the site shows an error instead of the page, and `jaspr build` stops. The message names the line and points at the problem:

```
Error on line 36, column 19 of content/sample_edits.yaml: title in sample edit 2: Expected </b> but found </i>.
   ╷
36 │       - <b>Trailer</i> that got the film
   │                   ^
   ╵
```

<sub><!-- agent-generated --><kbd>🤖 Agent-generated</kbd></sub>
