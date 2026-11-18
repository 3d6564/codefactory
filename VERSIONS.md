# Versions

CodeFactory uses semantic versioning for source snapshots. Tags use the form
`vMAJOR.MINOR.PATCH` and are annotated. Create a tag only from merged `main`.
Create the matching GitHub Release from that tag.

Users install a version from a trusted checkout with `./install.sh`. The
installer does not download CodeFactory or report its version. Update this file
with each version and release date before creating its tag.

## Releases

### v0.1.1 — 2026-11-18

- Fix CodeWriter's CodeBrief confirmation workflow: read scoped project
  instructions directly, distinguish failed checks from absent markers, and
  carry prior confirmation into context-compaction summaries.
- Add the CodeWriter README banner and name its stage in the CodeFactory
  banner.
- Extend offline checks for the confirmation contract, installed prompt copies,
  and README artwork.

### v0.1.0 — 2026-11-13

- Initial release of CodeBrief, CodeWriter, and CodeReview as independently
  installable capabilities, with agent and standalone skill formats for the
  supported hosts.
