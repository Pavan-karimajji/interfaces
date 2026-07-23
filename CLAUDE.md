# interfaces

The central contract repo — the single home for `.proto` schemas and shared
C++ interface headers.

## Role

Every cross-component contract is defined here and nowhere else. Consumers link
`AdasInterfaces::AdasInterfaces` and depend on interfaces, not on each other
(R-IFACE-1, R-ARCH-1).

## Local constraints

- **Folder = producer/organization, package = data domain** — independent axes.
  Producer folders (`PerceptionCore__Outputs/`, `Aeb__Outputs/`) sit beside
  shared `common/`, `perception/`, `isp/` under `proto/` (R-IFACE-2).
- **Verified vs. legacy provenance:** only types checked against physical
  reference material get producer folders + verbatim naming; everything else
  carries a `PROVENANCE:` comment (R-IFACE-3).
- Proto naming per R-NAME-4 (snake_case fields, except reference-derived copied
  verbatim). Register new protos in `CMakeLists.txt` (`adas_generate_protos`).
- All files use the `COMPONENT: INTERFACES` header.
- Add a proto/interface: `../../.claude/workflows/add_proto.md` /
  `../../.claude/workflows/add_interface.md`.

## AI operational layer — root-canonical

Part of `1v-superproject`. Cross-cutting rules/skills/templates/workflows live
once at the superproject root `.claude/` (spec:
`docs/ai_operational_layer_spec.md`). Load `../../.claude/rules/*`; do not
duplicate them here. This file holds only what is local to `interfaces`.
