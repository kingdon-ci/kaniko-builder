# Cold Storage Documentation Protocol

## Purpose
This directory contains documentation that has been **retired from active use** after the issues they described have been resolved and their information has been properly integrated into planned architecture or operational documentation.

## Protocol for Document Retirement

### When to Retire a Document
A document should be moved to cold storage when **ALL** of the following conditions are met:

1. **Issues Resolved**: All GitHub issues referenced in the document have been closed
2. **Information Preserved**: Key information has been migrated to "planned docs" (architecture, procedures, README)
3. **No Active References**: No active workflows, scripts, or processes depend on the document
4. **Redundancy Confirmed**: The document's content is adequately covered by maintained documentation

### Retirement Process

#### 1. Pre-Retirement Checklist
- [ ] Verify all referenced GitHub issues are closed
- [ ] Confirm information migration to planned docs
- [ ] Check for active references in:
  - GitLab CI pipelines
  - Shell scripts
  - Other documentation
  - README files

#### 2. Create Retirement Record
Before moving a document, create a `.retired-FILENAME.md` record:

```markdown
# Retirement Record: ORIGINAL_FILENAME.md

**Retirement Date**: YYYY-MM-DD
**Retired By**: Name/Handle

## Original Purpose
Brief description of what the document covered.

## Issues Addressed
- GitHub Issue #X - Brief description (CLOSED)
- GitHub Issue #Y - Brief description (CLOSED)

## Information Migration
- Key concept A → Migrated to `PLANNED_DOC.md` section X
- Key concept B → Migrated to `README.md` usage section
- Technical details → Migrated to `DEVELOPMENT.md`

## Verification
- [ ] All referenced issues closed
- [ ] No remaining TODOs or FIXMEs
- [ ] Information preserved in maintained docs
- [ ] No active dependencies confirmed
```

#### 3. Move to Cold Storage
```bash
mv DOCUMENT.md attic/cold-storage/
mv .retired-DOCUMENT.md attic/cold-storage/
```

#### 4. Update References
- Remove from main directory listings
- Update any remaining references to point to new location
- Add entry to this README's **Retired Documents** section

## Current Candidates for Retirement

### Ready for Retirement (After Issue Resolution)
These documents describe issues now tracked in GitHub and should be retired once those issues are closed:

1. **PROGRESS_REPORT.md** 
   - **Contains**: Status of Issues #1, #2, #3, #4
   - **Action Required**: Wait for issue resolution, then migrate historical context to DEVELOPMENT.md
   - **GitHub Issues**: #1, #2, #3, #4

2. **github-issues.md**
   - **Contains**: Issue descriptions now in GitHub
   - **Action Required**: Can retire immediately (redundant with GitHub)
   - **GitHub Issues**: #1, #2, #3, #4 (all created)

### Under Review
These documents may have ongoing value but need evaluation:

1. **IMPLEMENTATION_PLAN.md** (297 lines)
   - **Contains**: Multi-arch runner setup (may have ongoing value)
   - **Action Required**: Extract valuable operational procedures to DEVELOPMENT.md
   - **Decision Needed**: Keep infrastructure setup info or fully retire?

2. **SPEC.md** (222 lines)
   - **Contains**: Original requirements and vision
   - **Action Required**: Migrate core requirements to README.md
   - **Decision Needed**: Keep as historical reference or retire after migration?

## Retired Documents

*None yet - this section will list documents that have been successfully retired.*

## Archive vs Cold Storage

**Difference**:
- **`attic/` (Archive)**: Documents with potential ongoing reference value
- **`attic/cold-storage/` (Cold Storage)**: Documents that are redundant with maintained docs and resolved issues

**Rule**: Only move to cold storage when information is **fully preserved** elsewhere and **no ongoing reference value** exists.

## Maintenance

This directory should be reviewed quarterly to ensure:
- Retirement records are accurate
- No documents were prematurely retired
- Information migration was complete
- Directory doesn't become a dumping ground

## Emergency Recovery

If a cold storage document is needed urgently:
1. Check the retirement record for migration locations
2. If information is insufficient, temporarily restore from cold storage
3. Update the retirement record with lessons learned
4. Re-evaluate retirement decision