# Project Todo List

## Testing Tasks

### Weekly Goals
- [ ] Test weekly goal with strict tracking
  - [ ] Verify streak increments only when all selected days are completed
  - [ ] Verify streak resets when any selected day is missed
  - [ ] Test record updates when streak exceeds previous record
  - [ ] Test unchecking a completion and verify streak/record behavior

- [ ] Test weekly goal with lenient tracking
  - [ ] Verify streak increments when required number of days are completed (any days)
  - [ ] Verify streak resets when weekly quota is not met
  - [ ] Test record updates when streak exceeds previous record
  - [ ] Test unchecking a completion and verify streak/record behavior

### General Testing
- [ ] Test date simulator with weekly goals
  - [ ] Verify behavior across week boundaries
  - [ ] Test with different time zones
  - [ ] Verify record tracking across simulated dates

## Feature Implementation

### Weekly Goals
- [ ] Add weekly goal statistics view
  - [ ] Show weekly completion rate
  - [ ] Display selected days vs completed days
  - [ ] Add visual indicators for missed days

### UI Improvements
- [ ] Add visual feedback for weekly goal progress
  - [ ] Progress bar for weekly completion
  - [ ] Clear indication of remaining days in week
  - [ ] Visual distinction between strict and lenient tracking

## Documentation
- [ ] Update documentation for weekly goals
  - [ ] Document strict vs lenient tracking behavior
  - [ ] Add examples of weekly goal configurations
  - [ ] Document streak calculation rules

## Bug Fixes
- [ ] Fix record display for weekly goals
  - [ ] Ensure proper unit display (weeks vs days)
  - [ ] Verify record updates correctly
  - [ ] Test edge cases (week boundaries, time zones)

## Notes
- Use `// TODO:` comments in code for quick reminders
- Use `// FIXME:` comments for known issues
- Use `// MARK:` comments to organize code sections
- Update this file as new tasks are identified

## How to Use This File
1. Check off items as they are completed
2. Add new items under appropriate sections
3. Use `- [ ]` for unchecked items
4. Use `- [x]` for completed items
5. Add dates and notes as needed 