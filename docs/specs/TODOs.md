# TODOs

## Decisions to check

1. [ ] **Jaspr version.** The site uses Jaspr 0.24.0-beta.2 because the installed CLI (0.24.0-beta.1) won't build projects on the stable 0.23. Beta.2 is also the first version with `showModal()` on dialogs. Move `jaspr` and `jaspr_builder` in [pkgs/website/pubspec.yaml](../../pkgs/website/pubspec.yaml) to the stable 0.24 once it's out.
2. [ ] **YAML format.** The manager invited changes, so `sample_edits.yaml` changed:
   1. Sample edits are a list, so moving a block reorders them.
   2. `title` and `description` take any number of lines.
   3. A line that isn't needed is left out instead of set to `none`.

   Confirm with the manager. [pkgs/website/content/README.md](../../pkgs/website/content/README.md) explains the changes to them.
3. [ ] **Content fixes to match the design.** Confirm with the manager:
   1. The third title is "Professional Reel" on one line. The draft had a stray "into festivals" line copied from the trailer.
   2. There's a period after "7 Palms Entertainment".
   3. The 7 Palms Entertainment link opens in a new tab.
4. [ ] **Title weight.** The design shows "Award winning short film" in regular weight, but the trailer's untagged title lines in medium. The YAML can't express both, so all titles use medium as the base weight (`.sample-edit-title` in [sample_edit_card.dart](../../pkgs/website/lib/components/sample_edit_card.dart)). Confirm with the designer.
5. [ ] **Things the docs don't specify.** Confirm with the designer:
   1. The phone layout. Below 720 px the cards stack, with a full-width "Click to watch" bar.
   2. Hover states on the thumbnail, the "Click to watch" button and the links.
   3. A close button and Escape on the video player, in addition to clicking outside it.
   4. Videos autoplay with sound, because the visitor clicked to watch. Vimeo's embed code had `muted=1`; see `embedUrl` in [sample_edit.dart](../../pkgs/shared/lib/src/sample_edit.dart).

<sub><!-- agent-generated --><kbd>🤖 Agent-generated</kbd></sub>
