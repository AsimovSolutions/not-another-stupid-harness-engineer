# Promotion to the organisation document

A repository document describes one repository. The organisation document describes what its
repositories have in common, and it is derived from them — never written by hand.

## The rule

A canonical term that appears under the same section in two or more of an organisation's
repository documents is promoted to the organisation document. A term appearing in one stays
where it is.

Only `[observed: …]` entries are eligible. A `[default: …]` entry records that nothing was
found and a profile default was applied; promoting one would turn an assumption about a
repository into a convention of the organisation.

## Why the term and not the description

Comparison is on the normalised canonical term. Comparing descriptions would fail in both
directions: the same convention phrased two ways would not match, and two different
conventions phrased similarly might. The term is the key precisely because it is short and
mechanical.

Where a promoted term carries different descriptions across repositories, the description is
taken from the alphabetically first repository name. Not the longest, not the most recent —
either of those would make the output depend on something other than the inputs.

## The threshold is a guess

Two repositories sharing a library may reflect a convention or a coincidence. Two is a
starting point chosen because it is the smallest number that can show a pattern at all. It
should be revisited once there are organisations with enough analysed repositories to tell
the difference, and this paragraph should be rewritten with what was learned rather than
quietly deleted.

## Redundancy is deliberate

A repository document keeps every entry that applies to it, including entries also present in
the organisation document. Both files are generated and neither is maintained by hand, so the
duplication costs nothing — and a repository document that listed only its differences would
mislead anyone who read it on its own.
