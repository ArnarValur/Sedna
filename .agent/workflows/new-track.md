---
description: Create a new Conductor track with domain selection
---

# Create New Track Workflow

## Step 1: Gather Track Information

Ask the user for:
1. **Track name** (e.g., "User Settings Redesign")
2. **Brief description** — What does this track accomplish?

## Step 2: Domain Selection

Present domain options from `conductor/tracks.md` and ask user to select ONE.

> **Note:** The domain table is project-specific. Read the `## 🗂️ Domain Structure` section
> from `conductor/tracks.md` to get the available domains, paths, and caution levels.
>
> If the domain table is missing or empty, ask the user to define domains first.

For any domain marked 🔴 (Tread Carefully), remind the user of its sensitivity before proceeding.

## Step 3: Create Track Folder

Create folder with naming convention:
```
conductor/tracks/{domain}/{snake_case_name}_{YYYYMMDD}/
```

Example: `conductor/tracks/api/rate_limiting_20260215/`

## Step 4: Generate Files

Create in the new track folder:

### `metadata.json`

```json
{
  "track_id": "{snake_case_name}_{YYYYMMDD}",
  "type": "feature",
  "status": "new",
  "domain": "{domain}",
  "created_at": "{ISO timestamp}",
  "updated_at": "{ISO timestamp}",
  "description": "{user description}"
}
```

### `spec.md`

Document the feature/fix specification:

- What problem does this solve?
- Acceptance criteria
- Edge cases and constraints
- Dependencies on other tracks or systems

### `plan.md`

Phased implementation plan following TDD workflow:

1. Research & design phase
2. Implementation phase (with test-first sub-tasks)
3. Integration & polish phase
4. Verification & documentation phase

Each task should follow the format:
```markdown
- [ ] Task description
```

### `index.md`

```markdown
# Track {track_id} Context

- [Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Metadata](./metadata.json)
```

If `conductor/tracks/_templates/` exists, copy from there instead and populate.

## Step 5: Update tracks.md

Add new track entry under the **Active Tracks** section in `conductor/tracks.md`.

## Step 6: Confirm

Tell user: "Track created at `{path}`. Ready to start planning!"
