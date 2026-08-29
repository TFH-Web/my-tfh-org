# Rollback point — Discover deploy, 2026-08-28

Byte-exact copies of every production file touched by the Discover deploy,
pulled from https://rock.tfh.org immediately BEFORE it ran. Restore from here
if the deploy needs backing out.

| File here | Production location |
|---|---|
| `_css-overrides.less` | `/Themes/MyTFH-2021/Styles/_css-overrides.less` (Theme Styler → CSS Overrides) |
| `theme.css` | `/Themes/MyTFH-2021/Styles/theme.css` — compiled output, kept to prove what the build changed |
| `block-8826-content-6775.lava` | page 4049 Main block 8826 — **was empty** |
| `block-8827-content-6776.lava` | page 4050 Main block 8827 — **was empty** |

The two block files are 0 bytes. That is correct: both blocks existed in Rock
with a saved-but-empty content version before this deploy.

## To roll back

```
magnus write /FileContent/serverfs/Themes/MyTFH-2021/Styles/_css-overrides.less \
  -s https://rock.tfh.org -f _temporary-files/rollback-2026-08-28-discover/_css-overrides.less
magnus build /api/TriumphTech/Magnus/Build/serverfs/theme/MyTFH-2021 -s https://rock.tfh.org
```

Then re-check `theme.css` on the server against the copy here. The blocks can
be emptied from Rock's UI, or written back from the 0-byte files.

`_css-overrides.less` here is also byte-identical to the version at commit
d0fc807, so `git show d0fc807:theme/Styles/_css-overrides.less` is an equally
good source.
